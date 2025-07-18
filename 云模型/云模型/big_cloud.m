function [Exs, Ens, Hes, result_all] = big_cloud(data, n, m)
% data_num: 每个指标的数据数量
% indic_num: 指标的数量
[data_num, indic_num] = size(data);
fprintf('输入指标数量：%d\n', indic_num)
fprintf('每个指标的数据数量：%d\n', data_num)

% 初始化
Exs = zeros(1, indic_num);
Ens = zeros(1, indic_num);
Hes = zeros(1, indic_num);

% 依次计算云模型参数
for i = 1:indic_num
    % 计算第 i 个指标的云模型参数
    [Exs(i),Ens(i),Hes(i)] = my_cloud(data(:,i), n, m);
end

% 排列结果
result_all = [Ens; Exs; Hes];

% 打印结果
% disp('计算结果如下：')
% disp('Ex: ')
% disp(Exs)
% disp('En: ')
% disp(Ens)
% disp('He: ')
% disp(Hes)
end

function [Ex,En,He] = my_cloud(A,n,m)
%UNTITLED 求云模型的三个数字特征
%  由若干个云滴按照SBCT-1stM算法求解Ex，En和He
%  n为抽取样本个数，m为每个样本包含元素个数，n与m的乘积不一定等于样本总数
Ex=mean(A);
for i=1:n
    X{i}=datasample(A,m);
    DY(i)=var(X{i});
end
En=sqrt(0.5*sqrt(4*mean(DY).^2-2*var(DY)));
He=sqrt(mean(DY)-En.^2);
end
