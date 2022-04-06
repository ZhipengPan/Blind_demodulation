% �����²���
% ���ߣ� ��־��
% ʱ�䣺2022.04.05
% ���������
% output: ����ź�
% cur_time_out: ���һ�β�ֵλ�� 
 
% ���������
% input: �����ź�
% Fs��Դ������
% Fs_rsp�� Ŀ�������
% cur_time_ini�� ��ʼ��ֵλ��
function [output, cur_time_out] = func_downsample_cons(input, Fs, Fs_rsp, cur_time_ini)

input = input(:);
input_len = length(input);
output_len = floor((input_len - cur_time_ini) * Fs_rsp / Fs) + 1;
output = zeros(output_len, 1);
time_step = Fs / Fs_rsp;
cur_time = cur_time_ini;
integer = 0;
frac = 0;
for i = 1:output_len
  integer = floor(cur_time);
  frac = cur_time - floor(cur_time);
  if integer + 1 <= input_len
    output(i) = input(integer) + frac * (input(integer+1) - input(integer));
  end
  cur_time = cur_time + time_step;
end
cur_time_out = cur_time - input_len;
% win = fir1(13, 0.6, 'low'); 
% output = conv(output, win, 'same');
end