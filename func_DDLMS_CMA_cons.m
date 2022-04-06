% ��ģä�����㷨��CMA����ֱ���о�������С����������о��㷨
% ���ߣ� ��־��
% ʱ�䣺2022.04.05
% ��������
% ���������
% y: ����ź�
% e: ������ 
% w: �����˲���ϵ��
% x_buff: ������ݻ��棬���������
 
% ���������
% x: �����ź�
% w_in: �˲�����ʼֵ���״ε���Ϊ[];
% x_buff_in: �������ݻ��棬�״ε���Ϊ[];
% M���˲�������
% mu_CMA: CMA�����㷨�˲���Ȩֵ��������
% mu_LMS: LMS�����㷨�˲���Ȩֵ��������
% std_constel: ��׼�����������о�
function [y, e, w, x_buff] = func_DDLMS_CMA_cons(x, w_in, x_buff_in, M, mu_CMA, mu_LMS, std_constel)

% ��������ֵ
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
D = min(dist_constel); % ��������������������

CMA_R = mean(abs(std_constel).^4) / mean(abs(std_constel).^2); % CMAä����Rֵ

% step1: �㷨��ʼ��
% �˲���ϵ��
x = x(:);
x_buff_in = x_buff_in(:);
x = [x_buff_in; x];
if isempty(w_in)
  w = zeros(1,M);
  w((M+1)/2) = 1;
else
  w = w_in;
end
% ������������
N=length(x);
% ִ���㷨
m = 1;
y = zeros(N-M+1, 1);
e = zeros(N-M+1, 1);
for n = M:1:N 
    % ��������
    filter_in = x(n:-1:n-M+1);
    % �������
    y(m) = w*filter_in;
    % �о�
    [dist, ind_decis] = min(abs(y(m)*ones(std_constel_n, 1) - std_constel));
    % ѡ���㷨������������
    if dist < D/2
      e(m) = y(m) - std_constel(ind_decis);
      w = w - mu_LMS * e(m) * filter_in';
    else
      e(m) = y(m) * (abs(y(m))^2 - CMA_R);
      w = w - mu_CMA * e(m) * filter_in';
    end
    % �˲���ϵ������
    m = m + 1;
end
x_buff = x(N-M+2:N);
end