%% 云模型，将Ex、En、He数据替换成自己的数据即可
% Author：包子
% QQ/V：472770120
% x 表示云滴
% ux 表示隶属度（这里是“钟形”隶属度），意义是度量倾向的稳定程度
% Ex 云模型的数字特征，表示期望
% En 云模型的数字特征，表示熵
% He 云模型的数字特征，表示超熵

clc;clear all;close all;
Ex = [2.5000 	3.5000 	5.0000 	3.6890];
En = [0.1670 	0.1670 	0.0830 	0.9153];
He = [0.0080 	0.0800 	0.0800 	0.0805];
%云滴个数
n = 5000;
%绘图
figure(1)
for i = 1:length(Ex)
    for j = 1:n
        %计算以En为期望值，He^2为方差的正态随机En'
        En1 = normrnd(En(i),He(i),1);
        %计算以Ex为期望值，En'^2为方差的正态随机x
        x(j) = normrnd(Ex(i),En1,1);
        ux(j) = exp(-( x(j)-Ex(i))^2/(2*(En1^2)));
    end
    plot(x,ux,'.')
    hold on
end
legend('张三','李四','王五','赵六')



