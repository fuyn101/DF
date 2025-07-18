% TOPSIS计算(未改进定权)

% 导入数据
filename = 'C:\Users\admin\Desktop\211评估方法\特征数据.xls';
data = readtable(filename, 'Sheet', 1, 'VariableNamingRule', 'preserve');
[m, n] = size(data{:,:});
disp(['行列：', num2str(m), ' ', num2str(n)])

% 调用熵权法计算函数
Y_ij = entropy_weight(data);  % 标准化矩阵

% 假设已知权重w
% w = ...;

Z_ij = zeros(m, n);
for i = 1:m
    for j = 1:n
        Z_ij(i, j) = Y_ij{i, j} * w(j);
    end
end

Imax_j = max(Z_ij);  % 最优解
Imin_j = min(Z_ij);  % 最劣解

Dmax_ij = zeros(m, n);
Dmin_ij = zeros(m, n);
for i = 1:m
    for j = 1:n
        Dmax_ij(i, j) = (Imax_j(j) - Z_ij(i, j))^2;
        Dmin_ij(i, j) = (Imin_j(j) - Z_ij(i, j))^2;
    end
end

Dmax_i = sqrt(sum(Dmax_ij, 2));  % 最优解欧氏距离
Dmin_i = sqrt(sum(Dmin_ij, 2));  % 最劣解欧氏距离

C_i = Dmin_i ./ (Dmax_i + Dmin_i);  % 综合评价值

% 如果你想保存这些数据到Excel文件
% T = table(Dmax_i, Dmin_i, C_i, 'RowNames', data.Properties.RowNames, 'VariableNames', {'最优解', '最劣解', '综合评价值'});
% writetable(T, 'D:\\CRITIC\\Y_ij包括最优解最劣解距离贴进度.xls', 'Sheet', 'topsis贴进度包括最优解最劣解距离、最后的是综合贴进度', 'WriteRowNames', true);

% 熵权法计算函数
function Y_ij = entropy_weight(data)
    [m, n] = size(data);
    Y_ij = data;
    for i = 1:n
        col_name = data.Properties.VariableNames{i};
        if strcmp(col_name, '结构洞约束')  % 负向指标
            Y_ij{:, i} = (max(data{:, i}) - data{:, i}) ./ (max(data{:, i}) - min(data{:, i}));
        else  % 正向指标
            Y_ij{:, i} = (data{:, i} - min(data{:, i})) ./ (max(data{:, i}) - min(data{:, i}));
        end
    end
end
