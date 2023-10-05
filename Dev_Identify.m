% 导入数据并创建数据对象
clear;
identifyData=xlsread("Modelling_identify.xlsx");

data = iddata(identifyData(:,9),identifyData(:,11), 1);  % output为阶跃响应输出数据，input为阶跃响应输入数据，Ts为采样时间间隔

% 进行系统辨识
sys = n4sid(data, 1);  % n为系统模型的阶数

% 进行传递函数估计
tffun = tfest(data, 1, 0);  % np为传递函数的分子阶数，nz为传递函数的分母阶数
