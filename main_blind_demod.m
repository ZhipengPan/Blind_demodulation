% 盲解调主程序
% 作者： 潘志鹏
% 时间：2022.04.05
close all;
%==========================基本参数=============================
Fs      = 960e3;          % 采样率
Fc      = 200.01e3;       % 载频，故意引入10Hz频偏，验证克服频移特性
Fd      = 120e3;          % 符号速率
beta    = 0.25;           % 成型因子
Bw      = (1+beta) * Fd;  % 带宽
low_fir = fir1(34,Bw * 1.1 / 2 / (Fs / 2),chebwin(35,30));  % 低通滤波大约0.55BW
match_filt = rcosdesign(0.4,6,8,'sqrt');                    % 匹配滤波器                                   % 
isMultiLevel = 1;                                           % I、Q路是否为多电平;
%===============================================================
%===================调制方式参数================================
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
%========================盲解调相关参数=========================
mod_type = 'QAM'; % 调制类型，目前有QAM 8PSK BPSK 16APSK 32APSK
modOrder = 16;    % 调制阶数
mu_CMA = 0.0001;  % CMA盲均衡步进
mu_LMS = 0.002;   % DDLMS盲均衡步进
%===============================================================
%=======================连续解调相关参数========================
down_freq_ini_phase = 0;            % 下变频
match_filter_ini = [];              % 匹配滤波器初始值输入
match_filter_out = [];              % 匹配滤波器输出
down_sample_cur_time_ini = 1;       % 下采样
coarse_carrierSync_ini_phase = 0;   % 载波粗同步
data_buff_gardner_in = [];          % 符号定时同步
ini_state_gardner = [];
carrierSync_Costas_ini_state = [];  % 载波精同步
data_buff_CMA_in = [];              % 均衡
weight_ini_CMA = [];
%===============================================================
fid_in = fopen('wave_sin_Fs960K_Fc5e6_16QAM_SNR20dB.dat','r');
read_size = 25*1024;                % 每次读文件大小
figure;
while ~feof(fid_in)
data = fread(fid_in,read_size, 'int16','l');
% step1: 下变频到基带
[data_down, down_freq_phase] = func_down_freq_cons(data, Fc, Fs, down_freq_ini_phase);
down_freq_ini_phase = down_freq_phase;
% step2: 匹配滤波
[data_down_fil, match_filter_out] = filter(match_filt, 1, data_down, match_filter_ini);
match_filter_ini = match_filter_out;
% step3: 下采样，采样率变为符号速率的4倍
[data_resample, down_sample_cur_time] = func_downsample_cons(data_down_fil, Fs, 4*Fd, down_sample_cur_time_ini);
down_sample_cur_time_ini = down_sample_cur_time;
% step4: 基于FFT的载波粗同步
data_resample = data_resample ./ mean(abs(data_resample));
[data_coarse_carr_sync, esti_freq_offset, coarse_carrierSync_phase] = func_coarse_carrierSync_cons(data_resample, 4, 4*Fd, coarse_carrierSync_ini_phase);
coarse_carrierSync_ini_phase = coarse_carrierSync_phase;
% step5: 基于gardner的符号定时同步
data_coarse_carr_sync = data_coarse_carr_sync ./ max(abs(data_coarse_carr_sync));
[data_sym_sync, state_gardner, data_buff_gardner, ~, ~] = func_gardner_cons(data_coarse_carr_sync, ini_state_gardner, data_buff_gardner_in, isMultiLevel);
ini_state_gardner = state_gardner;
data_buff_gardner_in = data_buff_gardner;
% step6: 基于Costas环的载波精同步
data_sym_sync = data_sym_sync / mean(abs(data_sym_sync));
[data_carr_sync, PLL_e, PLL, carrierSync_Costas_state] = func_carrierSync_Costas_cons(data_sym_sync, carrierSync_Costas_ini_state, mod_type);
carrierSync_Costas_ini_state = carrierSync_Costas_state;
% step7: 基于判决反馈LMS算法和CMA算法的盲均衡
data_carr_sync = data_carr_sync / mean(abs(data_carr_sync));
[data_equa, e, w, data_buff_CMA]=func_DDLMS_CMA_cons(data_carr_sync, weight_ini_CMA, data_buff_CMA_in, 31,mu_CMA,mu_LMS, std_constel);
data_buff_CMA_in = data_buff_CMA;
weight_ini_CMA = w;
subplot(2,2,1);
plot(real(data_resample(1:4:end)), imag(data_resample(1:4:end)),'b*');
title('载波同步前')
subplot(2,2,2);
plot(real(data_sym_sync), imag(data_sym_sync),'r*');
title('载波粗同步+定时同步后')
subplot(2,2,3);
plot(real(data_carr_sync), imag(data_carr_sync),'g*');
title('载波精同步后');
subplot(2,2,4);
plot(real(data_equa), imag(data_equa),'k*');
title('均衡后');
pause(0.001);
end
fclose(fid_in);
