% ����FFT���ز���ͬ���㷨
% ���ߣ� ��־��
% ʱ�䣺2022.04.05
% ���������
% data_output: �ز���ͬ�����ź�
% esti_freq_offset: ����Ƶƫ
% phase: �����������������λֵ

% ���������
% data: �����ź�
% m: �źŵ�m�η���BPSK����2��QPSK��QAM����4��8PSK����8
% fs: ������
% ini_phase: �����������������ʼ��λֵ

function [data_output, esti_freq_offset, phase]=func_coarse_carrierSync_cons(data, m, fs, ini_phase)
  data = data(:);
  N = 2^nextpow2(fs); % ����ֹ��Ƶ�Ƶ�ʷֱ���Ϊ1��
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