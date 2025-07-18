function [weights, normalized_data] = EntropyWeightMethod(data_matrix, negative_columns)
% EntropyWeightMethod - 使用熵权法计算指标权重
%
% 语法: [weights, normalized_data] = EntropyWeightMethod(data_matrix, negative_columns)
%
% 输入:
%   data_matrix - m x n 数值矩阵, m为样本数, n为指标数
%   negative_columns - (可选) 一个行向量, 包含负向指标的列索引 (值越小越好)
%
% 输出:
%   weights - 1 x n 的权重向量
%   normalized_data - m x n 的标准化数据矩阵
%
% 示例:
%   data = [82, 89, 70; 75, 80, 85; 90, 85, 75];
%   negative_cols = [3]; % 第3列为负向指标
%   [w, norm_data] = EntropyWeightMethod(data, negative_cols);

%% 1. 输入处理
if nargin < 2
    negative_columns = []; % 默认为无负向指标
end

[m, n] = size(data_matrix);

%% 2. 数据标准化
normalized_data = zeros(m, n);
for j = 1:n
    col_data = data_matrix(:, j);
    min_val = min(col_data);
    max_val = max(col_data);
    range_val = max_val - min_val;
    
    % 处理常数列, 避免除以零
    if range_val == 0
        normalized_data(:, j) = 0.5; % 赋予一个中间值
        fprintf('警告: 指标 %d 为常数列, 标准化为 0.5.\n', j);
        continue;
    end
    
    % 根据指标类型(正向或负向)进行标准化
    if ismember(j, negative_columns)
        % 负向指标, 值越小越好
        normalized_data(:, j) = (max_val - col_data) / range_val;
    else
        % 正向指标, 值越大越好
        normalized_data(:, j) = (col_data - min_val) / range_val;
    end
end

%% 3. 计算各指标的熵值
E = zeros(1, n);
for j = 1:n
    col_sum = sum(normalized_data(:, j));
    
    % 处理列和为零的情况
    if col_sum == 0
        E(j) = 1; % 熵值最大, 表示无信息
        continue;
    end
    
    p = normalized_data(:, j) / col_sum;
    
    % 计算熵值, 处理 p_ij = 0 的情况
    entropy_sum = 0;
    for i = 1:m
        if p(i) > 0
            entropy_sum = entropy_sum + p(i) * log(p(i));
        end
    end
    E(j) = -1/log(m) * entropy_sum;
end

%% 4. 计算权重
G = 1 - E; % 计算差异系数 (冗余度)
weights = G / sum(G); % 归一化权重, 使其和为 1

end
