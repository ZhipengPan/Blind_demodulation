% ä���������
% ���ߣ� ��־��
% ʱ�䣺2022.04.05
close all;
%==========================��������=============================
Fs      = 960e3;          % ������
Fc      = 200.01e3;       % ��Ƶ����������10HzƵƫ����֤�˷�Ƶ������
Fd      = 120e3;          % ��������
beta    = 0.25;           % ��������
Bw      = (1+beta) * Fd;  % ����
low_fir = fir1(34,Bw * 1.1 / 2 / (Fs / 2),chebwin(35,30));  % ��ͨ�˲���Լ0.55BW
match_filt = rcosdesign(0.4,6,8,'sqrt');                    % ƥ���˲���                                   % 
isMultiLevel = 1;                                           % I��Q·�Ƿ�Ϊ���ƽ;
%===============================================================
%===================���Ʒ�ʽ����================================
% 16APSK
% M = [4 12];
% radii = [0.3606 1.1358];
% cmap = [12;14;15;13;4;0;8;10;2;6;7;3;11;9;1;5];
% modOrder = sum(M);
% std_constel = apskmod(0:modOrder-1,M,radii,'SymbolMapping',cmap,'PlotConstellation',true,'InputType','integer');
% QPSK
% std_constel = qammod(0:3,4,[0 1 3 2],'PlotConstellation',false,'UnitAveragePower',true);
% 8PSK
% std_constel = pskmod(0:7,8,pi/8);
% 16QAM
std_constel = qammod(0:15,16,0:15,'PlotConstellation',false,'UnitAveragePower',true);
%===============================================================
%========================ä�����ز���=========================
mod_type = 'QAM'; % �������ͣ�Ŀǰ��QAM 8PSK BPSK 16APSK 32APSK
modOrder = 16;    % ���ƽ���
mu_CMA = 0.0001;  % CMAä���ⲽ��
mu_LMS = 0.002;   % DDLMSä���ⲽ��
%===============================================================
%=======================���������ز���========================
down_freq_ini_phase = 0;            % �±�Ƶ
match_filter_ini = [];              % ƥ���˲�����ʼֵ����
match_filter_out = [];              % ƥ���˲������
down_sample_cur_time_ini = 1;       % �²���
coarse_carrierSync_ini_phase = 0;   % �ز���ͬ��
data_buff_gardner_in = [];          % ���Ŷ�ʱͬ��
ini_state_gardner = [];
carrierSync_Costas_ini_state = [];  % �ز���ͬ��
data_buff_CMA_in = [];              % ����
weight_ini_CMA = [];
%===============================================================
fid_in = fopen('wave_sin_Fs960K_Fc5e6_16QAM_SNR20dB.dat','r');
read_size = 25*1024;                % ÿ�ζ��ļ���С
figure;
while ~feof(fid_in)
data = fread(fid_in,read_size, 'int16','l');
% step1: �±�Ƶ������
[data_down, down_freq_phase] = func_down_freq_cons(data, Fc, Fs, down_freq_ini_phase);
down_freq_ini_phase = down_freq_phase;
% step2: ƥ���˲�
[data_down_fil, match_filter_out] = filter(match_filt, 1, data_down, match_filter_ini);
match_filter_ini = match_filter_out;
% step3: �²����������ʱ�Ϊ�������ʵ�4��
[data_resample, down_sample_cur_time] = func_downsample_cons(data_down_fil, Fs, 4*Fd, down_sample_cur_time_ini);
down_sample_cur_time_ini = down_sample_cur_time;
% step4: ����FFT���ز���ͬ��
data_resample = data_resample ./ mean(abs(data_resample));
[data_coarse_carr_sync, esti_freq_offset, coarse_carrierSync_phase] = func_coarse_carrierSync_cons(data_resample, 4, 4*Fd, coarse_carrierSync_ini_phase);
coarse_carrierSync_ini_phase = coarse_carrierSync_phase;
% step5: ����gardner�ķ��Ŷ�ʱͬ��
data_coarse_carr_sync = data_coarse_carr_sync ./ max(abs(data_coarse_carr_sync));
[data_sym_sync, state_gardner, data_buff_gardner, ~, ~] = func_gardner_cons(data_coarse_carr_sync, ini_state_gardner, data_buff_gardner_in, isMultiLevel);
ini_state_gardner = state_gardner;
data_buff_gardner_in = data_buff_gardner;
% step6: ����Costas�����ز���ͬ��
data_sym_sync = data_sym_sync / mean(abs(data_sym_sync));
[data_carr_sync, PLL_e, PLL, carrierSync_Costas_state] = func_carrierSync_Costas_cons(data_sym_sync, carrierSync_Costas_ini_state, mod_type);
carrierSync_Costas_ini_state = carrierSync_Costas_state;
% step7: �����о�����LMS�㷨��CMA�㷨��ä����
data_carr_sync = data_carr_sync / mean(abs(data_carr_sync));
[data_equa, e, w, data_buff_CMA]=func_DDLMS_CMA_cons(data_carr_sync, weight_ini_CMA, data_buff_CMA_in, 31,mu_CMA,mu_LMS, std_constel);
data_buff_CMA_in = data_buff_CMA;
weight_ini_CMA = w;
subplot(2,2,1);
plot(real(data_resample(1:4:end)), imag(data_resample(1:4:end)),'b*');
title('�ز�ͬ��ǰ')
subplot(2,2,2);
plot(real(data_sym_sync), imag(data_sym_sync),'r*');
title('�ز���ͬ��+��ʱͬ����')
subplot(2,2,3);
plot(real(data_carr_sync), imag(data_carr_sync),'g*');
title('�ز���ͬ����');
subplot(2,2,4);
plot(real(data_equa), imag(data_equa),'k*');
title('�����');
pause(0.001);
end
fclose(fid_in);
