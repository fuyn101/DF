function [fval]=cloud_TO(Ex,En,He,N,Exk,Enk) %求结果云与标准云的相似度
% EX为生成云滴的均值
% En为生成云滴的熵
% He为生成云滴的超熵
% N为生成云滴数量
% Exk为等级k的期望
% Enk为等级k的熵
result = zeros(N, 1);
for i=1:N
    En_r=randn(1)*He+En; %生成随机熵
    x_r=randn(1)*En_r+Ex;%生成随机数x
    result(i)=exp(-(x_r-Exk).^2./(2.*Enk.^2));%计算x_r对等级k的隶属度
end
fval = mean(result, 1);
