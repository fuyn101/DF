%% 云模型，计算综合评价云与标准云的相似度，将评价云的数字特征�?�和标准云的数字特征值替换成自己的数据即�?
% Author：包�?
% QQ/V�?472770120
clc
clear all
%评价云的数字特征�?
Ex = [72.9395, 81.2474, 67.9504, 71.0059, 73.1187];
En = [2.1063, 1.8141, 1.4780, 1.8556, 1.8175];
He = [0.3710, 0.2916, 0.3838, 0.4331, 0.3724];
%标准云的数字特征�?
Exv = [20,50,70,85];
Env = [6.67,3.33,3.33,1.67];
Hev = [0.5,0.5,0.5,0.5];

m = 3000;
for s = 1:length(Ex)
    for j = 1:length(Exv)
        for i = 1:m
            %第一步，计算以En为期望�?�，He^2为方差的正�?�随机En'
            En1(i) = normrnd(En(s),He(s));
            %第二步，生成以Ex为期望�?�，En1^2为方差的正�?�随机数x
            x(i) = normrnd(Ex(s),En1(i)^2);
            %第三步，计算θi
            theta(i) = exp(-(x(i) - Exv(j))^2/(2*Env(j)^2));
        end
        %第四步，计算相似�?
        Theta(s,j) = sum(theta)/m;
    end
end
disp(['评价云与标准云的相似度分别是�?'])
Theta

