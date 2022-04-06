% 恒模盲均衡算法（CMA）与直接判决反馈最小均方根误差判决算法
% 作者： 潘志鹏
% 时间：2022.04.05
% 参数定义
% 输出参数：
% y: 输出信号
% e: 误差输出 
% w: 最终滤波器系数
% x_buff: 输出数据缓存，连续解调用
 
% 输入参数：
% x: 输入信号
% w_in: 滤波器初始值，首次调用为[];
% x_buff_in: 输入数据缓存，首次调用为[];
% M：滤波器长度
% mu_CMA: CMA均衡算法滤波器权值调整参数
% mu_LMS: LMS均衡算法滤波器权值调整参数
% std_constel: 标准星座，用于判决
function [y, e, w, x_buff] = func_DDLMS_CMA_cons(x, w_in, x_buff_in, M, mu_CMA, mu_LMS, std_constel)

% 计算门限值
std_constel = std_constel(:);
std_constel_n = length(std_constel);
dist_constel = zeros(std_constel_n*(std_constel_n-1)/2, 1);
k = 0;
for i = 1:std_constel_n
  for j = i+1:std_constel_n
    k = k + 1;
    dist_constel(k) = abs(std_constel(i) - std_constel(j));
  end
end
D = min(dist_constel); % 任意两星座点的最近距离

CMA_R = mean(abs(std_constel).^4) / mean(abs(std_constel).^2); % CMA盲均衡R值

% step1: 算法初始化
% 滤波器系数
x = x(:);
x_buff_in = x_buff_in(:);
x = [x_buff_in; x];
if isempty(w_in)
  w = zeros(1,M);
  w((M+1)/2) = 1;
else
  w = w_in;
end
% 输入向量长度
N=length(x);
% 执行算法
m = 1;
y = zeros(N-M+1, 1);
e = zeros(N-M+1, 1);
for n = M:1:N 
    % 倒序输入
    filter_in = x(n:-1:n-M+1);
    % 计算输出
    y(m) = w*filter_in;
    % 判决
    [dist, ind_decis] = min(abs(y(m)*ones(std_constel_n, 1) - std_constel));
    % 选择算法并进行误差计算
    if dist < D/2
      e(m) = y(m) - std_constel(ind_decis);
      w = w - mu_LMS * e(m) * filter_in';
    else
      e(m) = y(m) * (abs(y(m))^2 - CMA_R);
      w = w - mu_CMA * e(m) * filter_in';
    end
    % 滤波器系数更新
    m = m + 1;
end
x_buff = x(N-M+2:N);
end