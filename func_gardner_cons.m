% Gardner符号定时同步算法
% 作者： 潘志鹏
% 时间：2022.04.05
% 输出参数：
% strobe: 符号同步后信号
% state
%   state(1): ipos-->当前插值位置
%   state(2): tedp-->前一插值点的值
%   state(3): tedm-->中间插值点的值
%   state(4): path2-->环路滤波器中延时支路的值
% data_buff_out: 数据缓存
% ted_vec：符号定时误差导致相位误差值
% uk_vec：符号定时误差值

% 输入参数：
% ini_state: 第一次调用为[]
%   ini_state(1): ipos-->当前插值位置
%   ini_state(2): tedp-->前一插值点的值
%   ini_state(3): tedm-->中间插值点的值
%   ini_state(4): path2-->环路滤波器中延时支路的值
% data_buff_in: 输入数据缓存部分
% isMultiLevel: I、Q路是否为多电平，1-->是, 0-->否

function [strobe, state, data_buff_out, ted_vec, uk_vec] = func_gardner_cons(data, ini_state, data_buff_in, isMultiLevel)

%=================2nd loop designed=================== 
BL    = 0.01; % 归一化噪声带宽
N     = 4; %每符号采样点数 
zeta  = 1; 
Kp    = 5.4;
seta  = (BL/N) / (zeta + 1/(4*zeta));
k1 = (-4*zeta*seta) / ((1+2*zeta*seta+seta^2)*Kp);
k2 = (-4*seta*seta) / ((1+2*zeta*seta+seta^2)*Kp);
%====================================================
tRate   = 4; 
k       = 1; 
if isempty(ini_state)
  ipos    = 5; 
  tedp    = data(1); 
  tedm    = data(3); 
  path2   = 0;
else
  ipos    = ini_state(1); 
  tedp    = ini_state(2); 
  tedm    = ini_state(3); 
  path2   = ini_state(4);
end

data = data(:);
data_buff_in = data_buff_in(:);
data = [data_buff_in; data];

while((ipos+tRate/2+2)<=length(data)-5) 
   %  step1 :estimate correct strobe vaule 
   mk=floor(ipos); 
   uk=ipos-mk; 
   uk_vec(2*k-1)=uk; 
   c_2=1/6*uk^3-1/6*uk; 
   c_1=-1/2*uk^3+1/2*uk^2+uk; 
   c_0=1/2*uk^3-uk^2-1/2*uk+1; 
   c1=-1/6*uk^3+1/2*uk^2-1/3*uk; 
   d2=data(mk+2); 
   d1=data(mk+1); 
   d0=data(mk); 
   d_1=data(mk-1); 
   iData=c_2*d2+c_1*d1+c_0*d0+c1*d_1; 
   strobe(k)=iData; 
   tedc =iData; 
   % step2: phase detect 
   if isMultiLevel
     gted = (real(tedm) - (real(tedp)+real(tedc)) * 0.58) * (sign(real(tedp)) - sign(real(tedc))) + ...
            (imag(tedm) - (imag(tedp)+imag(tedc)) * 0.58) * (sign(imag(tedp)) - sign(imag(tedc)));
   else
     gted=(sign(real(tedp))-sign(real(tedc))) * real(tedm) + (sign(imag(tedp))-sign(imag(tedc))) * imag(tedm); 
   end
   
   terror=gted; 
   ted_vec(k)=terror; 
   path1=gted*k1; 
   path2=path2+k2*gted; 
   test1(k)=path1; 
   test2(k)=path2; 
   ipos=ipos+tRate/2-(path1+path2)*tRate;% get the position of tedM
   % step3 :estimate the TedM vaule 
   mk=floor(ipos); 
   uk=ipos-mk; 
   mk_vec(k)=mk; 
   uk_vec(2*k)=uk; 
   c_2=1/6*uk^3-1/6*uk; 
   c_1=-1/2*uk^3+1/2*uk^2+uk; 
   c_0=1/2*uk^3-uk^2-1/2*uk+1; 
   c1=-1/6*uk^3+1/2*uk^2-1/3*uk; 
   d2=data(mk+2); 
   d1=data(mk+1); 
   d0=data(mk); 
   d_1=data(mk-1); 
   iData=c_2*d2+c_1*d1+c_0*d0+c1*d_1;  
   tedm=iData; 
   tedp=tedc; 
   ipos=ipos+tRate/2; 
   k=k+1; 
end 

state(1) = ipos - floor(ipos) + 2;
state(2) = tedp;
state(3) = tedm;
state(4) = path2;
data_buff_out = data(floor(ipos)-1:end);

% if isPlotTimeSyncErr
%   figure; 
%   subplot(3,1,1);
%   plot( ted_vec,'k-'); 
%   tit=sprintf('output of Time detector'); 
%   title(tit); 
%   subplot(3,1,2);
%   plot( uk_vec,'k-'); 
%   tit=sprintf('output of uk'); 
%   title(tit); 
%   subplot(3,1,3);
%   plot(test1,'b'); 
%   hold on; 
%   plot(test2,'r'); 
%   legend('path1','path2'); 
% end

end