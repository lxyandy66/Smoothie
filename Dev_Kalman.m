% % % 
clear;
testData=xlsread("Modelling_dbWithNet.xlsx");
%   数据说明
%     3为测量值
%     4为接收到的值
%     6为阀门当前开度
%     7位阀门设定值

% 过程传递函数转换为微分方程
%   tf2ss函数：用于从系统的传递函数建立系统的状态空间模型。
%   [A,B,C,D]=tf2ss(num,den)
%   参数num,den分别为系统传递函数的分母多项式系数和分子多项式系数
%   未知参数A,B,C,D分别为系统矩阵，输入矩阵（或控制矩阵），输出矩阵，直接传递矩阵。

% 系统状态建模
[A,B,C,D]=tf2ss(7,[80,1]);
% tfProcess=tf(0.02337,[1,0.01674]);
% sys=reduce(tfProcess,1);
% A=sys.A;
% B=sys.B;
N=1000;
T_sample=1; % 采样时间
Phi=expm(-0.008651*T_sample); %状态转移矩阵

%数据可信值
Q=[0.1,0.3];% 对估计值的信任程度 1为丢包时，2为正常时，同样可以考虑进行丢包函数处理
R=[0.3,0.1];% 对观察噪音的信任程度 %根据丢包和连续丢包次数进行函数编写#####
% 0相当于100%确定
% N表明Q与R关系

%数据导入
Valveopening=testData(1:N,6);
T_real=testData(1:N,3);%实际值，真实热电偶测量
T_rcv=testData(1:N,4);%接收值，相当于measure
%此处保证在无丢包更新后，所有的前值都为实际值
T_pre_update(1)=T_rcv(1);%预测值，完全根据物理模型推演算出
isRcv=testData(1:N,8);


%初始值
%后缀说明：kalman表示卡曼最优估计，pre表示预测，measure表示测量
T_start=22.5;
P_start=1; %温度初始估计的方差
T_kalman(1)=T_rcv(1);
P_kalman(1)=P_start;


%正式预测
for k=2:N
    T_pre_update(k)=Phi*T_kalman(k-1)+0.061*Valveopening(k-1)-0.07*(T_kalman(k-1)-25);
%     T_pre(k)=T_kalman(k-1);%此demo中温度连续，因此认为相等，即T(k)=T(k-1)
    P_pre(k)=P_kalman(k-1)+Q(isRcv(k)+1);
    K(k)=P_pre(k)/(P_pre(k)+R(isRcv(k)+1));%K(k)???????
%     isRcv(k)+1
    T_kalman(k)=T_pre_update(k)+K(k)*(T_rcv(k)-T_pre_update(k));
    P_kalman(k)=P_pre(k)-(K(k)*P_pre(k));
    
%     PI控制器更新阀门的动作



end

figure();
% plot(T_measured,"-k");
plot(T_kalman,"-k");
hold on
% plot(T_kalman,"r");
plot(T_pre_update,"g");
plot(T_real,"r");
plot(T_rcv,"b")
% ylim([-10,100]);
legend("Kalman估计值","估计值","温度测量值","温度接收值")