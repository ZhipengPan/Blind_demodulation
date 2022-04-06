% 符号速率估计, 图中峰值（0频除外）所对应的频率即为估计符号速率值
close all;
Fs = 960e3;
fid_in = fopen('wave_sin_Fs960K_Fc5e6_16QAM_SNR20dB.dat','r');
data = fread(fid_in,'int16','l');
fclose(fid_in);
data_hil = imag(hilbert(data));
data_env = data.^2 + data_hil.^2;
fft_num = 2^nextpow2(length(data_env));
f = Fs * (0:(fft_num/2))/fft_num;
data_env_fft = abs(fft(data_env, fft_num) / fft_num);
data_env_fft = data_env_fft(1:fft_num/2+1);
plot(f, data_env_fft);

