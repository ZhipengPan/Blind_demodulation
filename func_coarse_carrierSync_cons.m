% 基于FFT的载波粗同步算法
% 作者： 潘志鹏
% 时间：2022.04.05
% 输出参数：
% data_output: 载波粗同步后信号
% esti_freq_offset: 估计频偏
% phase: 连续解调所需的输出相位值

% 输入参数：
% data: 输入信号
% m: 信号的m次方，BPSK采用2，QPSK、QAM采用4、8PSK采用8
% fs: 采样率
% ini_phase: 连续解调所需的输入初始相位值

function [data_output, esti_freq_offset, phase]=func_coarse_carrierSync_cons(data, m, fs, ini_phase)
  data = data(:);
  N = 2^nextpow2(fs); % 假设粗估计的频率分辨率为1；
  fft_data = fftshift(abs(fft(data.^m, N)));
  fshift = (-N/2:N/2-1)*(fs/N); % zero-centered frequency range
  search_ind = find(abs(fshift)<=fs/8);

  fshift_range = fshift(search_ind);
  fft_data_range = fft_data(search_ind);
  [~, max_p] = max(fft_data_range);
  f_max = fshift_range(max_p);
  esti_freq_offset = f_max / m;
  data_output = data .* exp(-1i * 2 * pi * esti_freq_offset * (0:length(data)-1)'/fs - 1i * ini_phase);
  phase = mod(2 * pi * esti_freq_offset * length(data) / fs + ini_phase, 2*pi);
end