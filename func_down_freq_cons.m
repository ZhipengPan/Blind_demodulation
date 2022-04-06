% �����±�Ƶ
% ���ߣ� ��־��
% ʱ�䣺2022.04.05
% ���������
% data_out: ����ź�
% phase: �ź����һ�����������λ 
 
% ���������
% data: �����ź�
% Fc���ز�Ƶ��
% Fs�� ������
% ini_phase�� ��ʼ��λ

function [data_out, phase] = func_down_freq_cons(data, Fc, Fs, ini_phase)
  data_out = data .* exp(-1i * 2 * pi * Fc * (0:length(data)-1)' / Fs - 1i * ini_phase);
  phase = mod(2 * pi * Fc * length(data) / Fs + ini_phase, 2*pi);
end