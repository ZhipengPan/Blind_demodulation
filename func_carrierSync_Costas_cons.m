% Costas��ʵ���ز�ͬ��
% ���ߣ� ��־��
% ʱ�䣺2022.04.05
% ���������
% Signal_PLL: ����ź�
% e: ��λ������ 
% lambda: ������λ���
% state_out��
%   state_out(1): data(end)-->���һ��dataֵ(����������ֵ)�����������
%   state_out(2): lambda--> ������λ�����������
%   state_out(3): e-->���������������ѹ�źţ����������
%   state_out(4): psi-->��·�˲�����һ·��ʱ�źţ����������
 
% ���������
% data: �����ź�
% ini_state����һ�ε���Ϊ[]
%   ini_state(1): data(end)-->���һ��dataֵ(����������ֵ)�����������
%   ini_state(2): lambda--> ��ʼ��λ�����������
%   ini_state(3): e-->���������������ѹ�źţ����������
%   ini_state(4): psi-->��·�˲�����һ·��ʱ�źţ����������
% mod_type�����Ʒ�ʽ���� 'BPSK', 'PAM','QPSK','QAM','8PSK'
function [Signal_PLL,e,lambda, state_out]=func_carrierSync_Costas_cons(data, ini_state, mod_type)


% Ko=1;                           %ѹ����������               
% Kd=1;                           %����������  
% K=Ko*Kd;                        %������
% sigma=0.707;                    %��·����ϵ��,һ����Ϊ0.707
% BL=0.98*Fd;            %��·��Ч��������
% Wn=8*sigma*BL/(1+4*sigma^2);    %��·�����𵴽�Ƶ��
% T_nco=Ts*decimator;             %ѹ������NCOƵ���ָ�������
% K1=(2*sigma*Wn*T_nco)/(K);      %��·�˲���ϵ��K1
% K2=((T_nco*Wn)^2)/(K);          %��·�˲���ϵ��K2  

K0 = 1; % phase recovery gain, K0, is equal to the number of samples per symbol
if strcmpi(mod_type, '8PSK') 
  Kp = 1; % BPSK, PAM, QAM, QPSK, or OQPSK	Kp = 2; 8-PSK, Kp = 1
else
  Kp = 2;
end
Bn = 0.001; % ��һ����·�˲�������
zeta = 0.4; % damping factor
seta = Bn / (zeta + 1/(4*zeta));
d = 1 + 2*zeta*seta + seta^2;
g1 = 4*(seta^2/d)/(Kp*K0);
g2 = 4*zeta*(seta/d) / (Kp*K0);

% g1 = 0.022013;                    %��·�˲���ϵ��C1
% g2 = 0.00024722;                  %��·�˲���ϵ��C2 

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
        Signal_PLL(i)=data(i)*exp(-1i*mod(lambda(i-1),2*pi));  %�õ���·�˲���ǰ�������������
        I_PLL(i)=real(Signal_PLL(i));                                      %��������I·������Ϣ����
        Q_PLL(i)=imag(Signal_PLL(i));                                      %��������Q·������Ϣ����
        % ����źż��㣬��ͬ�ĵ��Ʒ�ʽ���Բ��ò�ͬ�Ĺ�ʽ
        if strcmpi(mod_type, 'QPSK') || strcmpi(mod_type, 'QAM')
          e(i)=sign(I_PLL(i))*Q_PLL(i) - sign(Q_PLL(i))*I_PLL(i);   %���������������ѹ�ź�
        elseif strcmpi(mod_type, 'BPSK') || strcmpi(mod_type, 'PAM')
          e(i)=sign(I_PLL(i))*Q_PLL(i);                              %���������������ѹ�ź�
        elseif strcmpi(mod_type, '8PSK')
          if I_PLL(i) >= Q_PLL(i)
            e(i)=sign(I_PLL(i))*Q_PLL(i) - (sqrt(2)-1)*sign(Q_PLL(i))*I_PLL(i);   %���������������ѹ�ź�
          else
            e(i)=(sqrt(2)-1)*sign(I_PLL(i))*Q_PLL(i) - sign(Q_PLL(i))*I_PLL(i);   %���������������ѹ�ź�
          end
        end
%         p(i)=e(i)*g1+psi(i-1);              % ����ѹ������������ź�Ƶ��
%         psi(i) = e(i)*g2 + psi(i-1);
%         lambda(i)=lambda(i-1)+p(i);         % ѹ������������λ����
        
        psi(i)=e(i)*g1+psi(i-1);              % ����ѹ������������ź�Ƶ��
        lambda(i)=lambda(i-1)+ e(i-1)*g2 + psi(i-1);         % ѹ������������λ����
end

Signal_PLL = Signal_PLL(2:end);
state_out(1) = data(i); % ���⼷һ������ȥ
state_out(2) = lambda(i);
state_out(3) = e(i);
state_out(4) = psi(i);
end