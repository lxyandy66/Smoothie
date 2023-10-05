% % % 
clear;

% 过程传递函数转换为微分方程
%   tf2ss函数：用于从系统的传递函数建立系统的状态空间模型。
%   [A,B,C,D]=tf2ss(num,den)
%   参数num,den分别为系统传递函数的分母多项式系数和分子多项式系数
%   未知参数A,B,C,D分别为系统矩阵，输入矩阵（或控制矩阵），输出矩阵，直接传递矩阵。

% 系统状态建模
[A,B,C,D]=tf2ss(3.36,[1368,524,43.6,1]);
N=250;
T_sample=1; % 采样时间
Phi=expm(A*T_sample); %状态转移矩阵

%数据可信值
Q=0.01;% 对估计值的信任程度
R=0.36;% 对观察噪音的信任程度

%初始值
%后缀说明：kalman表示卡曼最优估计，pre表示预测，measure表示测量
T_measured=10+randn(1,N);
T_start=12.5;
P_start=2; %温度初始估计的方差
T_kalman(1)=T_start;
P_kalman(1)=P_start;


%正式预测
for k=2:N
    T_pre(k)=T_kalman(k-1);%此demo中温度连续，因此认为相等，即T(k)=T(k-1)
    P_pre(k)=P_kalman(k-1)+Q;
    K(k)=P_pre(k)/(P_pre(k)+R);%K(k)???????
    T_kalman(k)=T_pre(k)+K(k)*(T_measured(k)-T_pre(k));
    P_kalman(k)=P_pre(k)-(K(k)*P_pre(k));
end

figure();
plot(T_measured,"-k");
hold on
plot(T_kalman,"r");
legend("温度测量值","Kalman估计值")