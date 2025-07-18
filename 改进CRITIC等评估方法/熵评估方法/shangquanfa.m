% 导入必要的工具包
% 熵权法

% 读取Excel数据
data = readtable('C:\Users\admin\Desktop\211评估方法\特征数据.xls', 'Sheet', 1, 'VariableNamingRule', 'preserve');

[m, n] = size(data); % 获取行数m和列数n

% 调用矩阵标准化函数
Y_ij_data = Y_ij(data); % 标准化矩阵

% 调用计算熵值函数
E_j_val = E_j(Y_ij_data); % 熵值
G_j = 1 - E_j_val; % 计算差异系数
W_j = G_j ./ sum(G_j); % 计算权重
disp(W_j);

WW = array2table(W_j', 'VariableNames', {'指标权重'}, 'RowNames', data.Properties.VariableNames);
disp(WW);

% 如果你想将标准化矩阵和指标权重保存至Excel，取消下面两行的注释
% writetable(Y_ij_data, 'D:\\Study\\Y_ij.xls', 'Sheet', 'Y_ij');
% writetable(WW, 'D:\\Study\\WW.xls', 'Sheet', 'WW');

% 矩阵标准化 (min-max标准化) 函数定义
function Y = Y_ij(data1)
    [m, n] = size(data1);
    for j = 1:n
        colName = data1.Properties.VariableNames{j};
        disp(colName);
        %if strcmp(colName, sprintf('X%d负', j)) %负向指标
        if strcmp(colName, '结构洞约束') %负向指标
            data1.(colName) = (max(data1.(colName)) - data1.(colName)) ...
                ./ (max(data1.(colName)) - min(data1.(colName)));
        else
            data1.(colName) = (data1.(colName) - min(data1.(colName))) ...
                ./ (max(data1.(colName)) - min(data1.(colName)));
        end
    end
    Y = data1;
end

% 计算熵值函数定义
function E = E_j(data2)
    [m, n] = size(data2);
    E = zeros(m, n);
    data2 = table2array(data2);
    for i = 1:m
        for j = 1:n
            if data2(i, j) == 0
                e_ij = 0;
            else
                P_ij = data2(i, j) / sum(data2(:, j)); % 计算比重
                e_ij = (-1 / log(m)) * P_ij * log(P_ij);
            end
            E(i, j) = e_ij;
        end
    end
    E = sum(E, 1);
end
