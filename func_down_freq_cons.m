% 连续下变频
% 作者： 潘志鹏
% 时间：2022.04.05
% 输出参数：
% data_out: 输出信号
% phase: 信号最后一个采样点的相位 
 
% 输入参数：
% data: 输入信号
% Fc：载波频率
% Fs： 采样率
% ini_phase： 初始相位

function [data_out, phase] = func_down_freq_cons(data, Fc, Fs, ini_phase)
  data_out = data .* exp(-1i * 2 * pi * Fc * (0:length(data)-1)' / Fs - 1i * ini_phase);
  phase = mod(2 * pi * Fc * length(data) / Fs + ini_phase, 2*pi);
end