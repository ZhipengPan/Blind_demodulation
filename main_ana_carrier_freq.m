% 信号载频分析
close all;
Fs = 960e3;
fid_in = fopen('wave_sin_Fs960K_Fc5e6_16QAM_SNR20dB.dat','r');
data = fread(fid_in,'int16','l');
fclose(fid_in);
[pxx,f] = pwelch(data,[],[],Fs/2,Fs);
data_pxx = pow2db(pxx);
data_pxx_max = max(data_pxx);
data_pxx_th = 10^(-5/10) * data_pxx_max;
plot(f, data_pxx,'b-');
hold on;
plot(f, data_pxx_th * ones(length(f), 1), 'r-.','LineWidth',1.5);
ind_f = find(data_pxx > data_pxx_th);
Fc_est = mean(f(ind_f));
plot(f(ind_f), data_pxx(ind_f),'m.');
plot([Fc_est Fc_est], [-40 20], 'k-.','LineWidth',1.5)
hold off;
legend('功率谱','门限值','门限值以上频率点','载频估计值');

xlabel('Frequency (Hz)')
ylabel('PSD (dB/Hz)')
fprintf('载频估计值为%.5f\n',Fc_est);