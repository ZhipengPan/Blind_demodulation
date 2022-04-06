% 连续下采样
% 作者： 潘志鹏
% 时间：2022.04.05
% 输出参数：
% output: 输出信号
% cur_time_out: 最后一次插值位置 
 
% 输入参数：
% input: 输入信号
% Fs：源采样率
% Fs_rsp： 目标采样率
% cur_time_ini： 初始插值位置
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