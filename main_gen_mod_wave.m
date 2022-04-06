% 仿真QPSK、QAM、APSK(S2X标准)波形
close all;
% M = 16;
% stdSuffix = 's2x';
% x = (0:M-1);
% y = dvbsapskmod(x,M,stdSuffix,'PlotConstellation',true,'UnitAveragePower',true);
% r = mean(abs(y.^2));
% cmap_inner = [12;14;15;13];
% cmap_outer = [4;0;8;10;2;6;7;3;11;9;1;5];
% y_inner = dvbsapskmod(cmap_inner,M,stdSuffix,'UnitAveragePower',true);
% r_inner = sqrt(mean(abs(y_inner.^2)));
% y_outer = dvbsapskmod(cmap_outer,M,stdSuffix,'UnitAveragePower',true);
% r_outer = sqrt(mean(abs(y_outer.^2)));

M = [4 12];
radii = [0.3606 1.1358];
cmap = [12;14;15;13;4;0;8;10;2;6;7;3;11;9;1;5];
% modOrder = sum(M);
% modOrder = 4;
% x = randi([0,7],160000,1);
% fid_msg = fopen('source_bit_M8.dat','w');
% fwrite(fid_msg, x, 'uint8','l');
% fclose(fid_msg);
% x = 0:modOrder-1;
% y = apskmod(x,M,radii,'SymbolMapping',cmap,'PlotConstellation',true,'InputType','integer');
% x = randi([0,modOrder-1],160000,1);

% fid_msg = fopen('source_bit_M8.dat','r');
% x = fread(fid_msg, 'uint8','l');
% fclose(fid_msg);
% y = apskmod(x,16,radii,'SymbolMapping',cmap,'PlotConstellation',true,'InputType','integer');
% y = qammod(x,16,[0:15],'PlotConstellation',true,'UnitAveragePower',true);

x = randi([0,7],160000,1);
y = pskmod(x,8,pi/8);
an = real(y);
bn = imag(y);
beta = 0.25;
span = 6;
sps = 8;
Fs = 960e3;
Fc = 5e6; % 注意载频为5e6的信号，在经过Fs采样率采样后信号的中频变为了Fc-N*Fs(N为保证Fc-N*Fs>0的最大整数)
BW = (Fs / sps) * (1 + beta);
h_shape = rcosdesign(beta,span,sps,'sqrt');
an_shape = upfirdn(an, h_shape, sps);
bn_shape = upfirdn(bn, h_shape, sps);


I_wave = an_shape .* cos(2*pi*Fc*(0:length(an_shape)-1)' / Fs);
Q_wave = bn_shape .* (-sin(2*pi*Fc*(0:length(bn_shape)-1)' / Fs));
trans_wave = I_wave + Q_wave;
SNR_dB = 20;
SNR = 10^(SNR_dB/10);
noise = sqrt(mean(trans_wave.^2) / SNR) * randn(length(trans_wave),1);
recv_wave = trans_wave + noise;
plot(recv_wave);
fid_out = fopen('wave_sin_Fs960K_Fc5e6_8PSK_SNR20dB.dat','w');
fwrite(fid_out,recv_wave*4096,'int16','l');
fclose(fid_out);
