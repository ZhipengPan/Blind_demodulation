% Costas环实现载波同步
% 作者： 潘志鹏
% 时间：2022.04.05
% 输出参数：
% Signal_PLL: 输出信号
% e: 相位误差输出 
% lambda: 估计相位输出
% state_out：
%   state_out(1): data(end)-->最后一个data值(可以是任意值)，连续解调用
%   state_out(2): lambda--> 最终相位，连续解调用
%   state_out(3): e-->鉴相器的输出误差电压信号，连续解调用
%   state_out(4): psi-->环路滤波器的一路延时信号，连续解调用
 
% 输入参数：
% data: 输入信号
% ini_state：第一次调用为[]
%   ini_state(1): data(end)-->最后一个data值(可以是任意值)，连续解调用
%   ini_state(2): lambda--> 初始相位，连续解调用
%   ini_state(3): e-->鉴相器的输出误差电压信号，连续解调用
%   ini_state(4): psi-->环路滤波器的一路延时信号，连续解调用
% mod_type：调制方式，有 'BPSK', 'PAM','QPSK','QAM','8PSK'
function [Signal_PLL,e,lambda, state_out]=func_carrierSync_Costas_cons(data, ini_state, mod_type)


% Ko=1;                           %压控振荡器增益               
% Kd=1;                           %鉴相器增益  
% K=Ko*Kd;                        %总增益
% sigma=0.707;                    %环路阻尼系数,一般设为0.707
% BL=0.98*Fd;            %环路等效噪声带宽
% Wn=8*sigma*BL/(1+4*sigma^2);    %环路自由震荡角频率
% T_nco=Ts*decimator;             %压控振荡器NCO频率字更新周期
% K1=(2*sigma*Wn*T_nco)/(K);      %环路滤波器系数K1
% K2=((T_nco*Wn)^2)/(K);          %环路滤波器系数K2  

K0 = 1; % phase recovery gain, K0, is equal to the number of samples per symbol
if strcmpi(mod_type, '8PSK') 
  Kp = 1; % BPSK, PAM, QAM, QPSK, or OQPSK	Kp = 2; 8-PSK, Kp = 1
else
  Kp = 2;
end
Bn = 0.001; % 归一化环路滤波器带宽
zeta = 0.4; % damping factor
seta = Bn / (zeta + 1/(4*zeta));
d = 1 + 2*zeta*seta + seta^2;
g1 = 4*(seta^2/d)/(Kp*K0);
g2 = 4*zeta*(seta/d) / (Kp*K0);

% g1 = 0.022013;                    %环路滤波器系数C1
% g2 = 0.00024722;                  %环路滤波器系数C2 

data = data(:);
data_len = length(data);

if isempty(ini_state)
  lambda = zeros(data_len,1);
  e = zeros(data_len,1);
  psi = zeros(data_len,1);
else
  data = [ini_state(1); data(:)];
  data_len = data_len + 1;
  lambda = [ini_state(2); zeros(data_len-1,1)];
  e = [ini_state(3); zeros(data_len-1,1)];
  psi = [ini_state(4); zeros(data_len-1,1)];
end

Signal_PLL=zeros(data_len,1);
I_PLL=zeros(data_len,1);
Q_PLL=zeros(data_len,1);

% p=zeros(data_len,1);

if strcmpi(mod_type, '16APSK')
   mod_type = 'QPSK';
   data = data.^3;
elseif strcmpi(mod_type, '32APSK')
   mod_type = 'QPSK';
   data = data.^4;
   data = data * exp(1i*pi/4);
end

for i=2:data_len
        Signal_PLL(i)=data(i)*exp(-1i*mod(lambda(i-1),2*pi));  %得到环路滤波器前的相乘器的输入
        I_PLL(i)=real(Signal_PLL(i));                                      %鉴相器的I路输入信息数据
        Q_PLL(i)=imag(Signal_PLL(i));                                      %鉴相器的Q路输入信息数据
        % 误差信号计算，不同的调制方式可以采用不同的公式
        if strcmpi(mod_type, 'QPSK') || strcmpi(mod_type, 'QAM')
          e(i)=sign(I_PLL(i))*Q_PLL(i) - sign(Q_PLL(i))*I_PLL(i);   %鉴相器的输出误差电压信号
        elseif strcmpi(mod_type, 'BPSK') || strcmpi(mod_type, 'PAM')
          e(i)=sign(I_PLL(i))*Q_PLL(i);                              %鉴相器的输出误差电压信号
        elseif strcmpi(mod_type, '8PSK')
          if I_PLL(i) >= Q_PLL(i)
            e(i)=sign(I_PLL(i))*Q_PLL(i) - (sqrt(2)-1)*sign(Q_PLL(i))*I_PLL(i);   %鉴相器的输出误差电压信号
          else
            e(i)=(sqrt(2)-1)*sign(I_PLL(i))*Q_PLL(i) - sign(Q_PLL(i))*I_PLL(i);   %鉴相器的输出误差电压信号
          end
        end
%         p(i)=e(i)*g1+psi(i-1);              % 控制压控振荡器的输出信号频率
%         psi(i) = e(i)*g2 + psi(i-1);
%         lambda(i)=lambda(i-1)+p(i);         % 压控振荡器进行相位调整
        
        psi(i)=e(i)*g1+psi(i-1);              % 控制压控振荡器的输出信号频率
        lambda(i)=lambda(i-1)+ e(i-1)*g2 + psi(i-1);         % 压控振荡器进行相位调整
end

Signal_PLL = Signal_PLL(2:end);
state_out(1) = data(i); % 任意挤一个数进去
state_out(2) = lambda(i);
state_out(3) = e(i);
state_out(4) = psi(i);
end