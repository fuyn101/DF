% 导入数据TOPSIS法(改进定权)综合评价
[data, txtData, rawData] = xlsread('C:\Users\admin\Desktop\211评估方法\特征数据.xls', 1);
labels = txtData(1, 2:end); % 所需的标签
data = data(:, 2:end); % 获取对应的数值数据

[m, n] = size(data); % 获取行数和列数
fprintf('行列：%d %d\n', m, n);

% 示例权重向量，您需要根据实际情况定义或计算权重
GJDQ = ones(1, n) / n; % 示例：所有指标权重相等

Y_ij = Y_ij_func(data, labels); % 调用矩阵标准化函数

None_ij = NaN(m, n); % 新建NaN矩阵

% 如果需要保存标准化矩阵到Excel，取消以下注释
% xlswrite('D:\\xuemei\\Y_ij沧州数据标准化.xls', Y_ij, '标准化');

% 计算加权标准化矩阵Z_ij
Z_ij = zeros(m, n);
for i = 1:m
    for j = 1:n
        Z_ij(i, j) = Y_ij(i, j) * GJDQ(j);
    end
end

Imax_j = max(Z_ij, [], 1); % 最优解
Imin_j = min(Z_ij, [], 1); % 最劣解

Dmax_ij = zeros(m, n);
Dmin_ij = zeros(m, n);
for i = 1:m
    for j = 1:n
        Dmax_ij(i, j) = (Imax_j(j) - Z_ij(i, j))^2;
        Dmin_ij(i, j) = (Imin_j(j) - Z_ij(i, j))^2;
    end
end

Dmax_i = sqrt(sum(Dmax_ij, 2)); % 最优解欧氏距离
Dmin_i = sqrt(sum(Dmin_ij, 2)); % 最劣解欧氏距离

C_i = Dmin_i ./ (Dmax_i + Dmin_i); % 综合评价值

% 打印综合评价值
disp(['未改进TOPSIS综合贴进度', num2str(C_i')]);

% 如需将结果保存到Excel，请取消以下注释
% T = table(Dmax_i, Dmin_i, C_i, 'RowNames', rawData(2:end, 1), 'VariableNames', {'最优解', '最劣解', '综合评价值'});
% writetable(T, 'D:\\CRITIC\\Y_ij包括最优解最劣解距离贴进度.xls', 'Sheet', 'topsis贴进度包括最优解最劣解距离、最后的是综合贴进度', 'WriteRowNames', true);

% 如果只需要综合评价值
% T2 = table(C_i, 'RowNames', rawData(2:end, 1), 'VariableNames', {'综合评价值'});
% writetable(T2, 'D:\\lunwen\\改进critic综合贴进度.xls', 'Sheet', 'topsis综合贴进度', 'WriteRowNames', true);

% 矩阵标准化(min-max标准化) 函数定义
function standardizedData = Y_ij_func(data, labels)
    [m, n] = size(data);
    standardizedData = data;
    for i = 1:n
        if strcmp(labels{i}, '结构洞约束') % 负向指标
            standardizedData(:, i) = (max(data(:, i)) - data(:, i)) ./ (max(data(:, i)) - min(data(:, i)));
        else % 正向指标
            standardizedData(:, i) = (data(:, i) - min(data(:, i))) ./ (max(data(:, i)) - min(data(:, i)));
        end
    end
end
