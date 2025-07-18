function [fval]=cloud_TO(Ex,En,He,N,Exk,Enk) %���������׼�Ƶ����ƶ�
% EXΪ�����Ƶεľ�ֵ
% EnΪ�����Ƶε���
% HeΪ�����Ƶεĳ���
% NΪ�����Ƶ�����
% ExkΪ�ȼ�k������
% EnkΪ�ȼ�k����
result = zeros(N, 1);
for i=1:N
    En_r=randn(1)*He+En; %���������
    x_r=randn(1)*En_r+Ex;%���������x
    result(i)=exp(-(x_r-Exk).^2./(2.*Enk.^2));%����x_r�Եȼ�k��������
end
fval = mean(result, 1);
