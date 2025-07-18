function [weights, normalized_data] = EWMshangquan(data_matrix, negative_columns)
% 熵权法 - 直接输入数据版
% 输入:
%   data_matrix - m×n数值矩阵，m个样本×n个指标
%   negative_columns - 负向指标的列索引(可选)

% 输出:
%   weights - 1×n权重向量
%   normalized_data - 标准化后的数据矩阵
%
% 示例:
%   data = [82, 89, 70; 75, 80, 85; 90, 85, 75];
%   negative_cols = [3]; % 第3列为负向指标
%   [w, norm_data] = entropy_weight_direct(data, negative_cols);

%% 参数处理
if nargin < 2
    negative_columns = []; % 默认无负向指标
end

[m, n] = size(data_matrix);

%% 数据标准化
normalized_data = zeros(m, n);
for j = 1:n
    col_data = data_matrix(:, j);
    min_val = min(col_data);
    max_val = max(col_data);
    range_val = max_val - min_val;
    
    % 处理常数列
    if range_val == 0
        normalized_data(:, j) = 0.5;
        fprintf('指标%d为常数列, 标准化为0.5\n', j);
        continue;
    end
    
    % 负向指标处理
    if ismember(j, negative_columns)
        normalized_data(:, j) = (max_val - col_data) / range_val;
    else
        normalized_data(:, j) = (col_data - min_val) / range_val;
    end
end

%% 计算熵值
E = zeros(1, n);
for j = 1:n
    col_sum = sum(normalized_data(:, j));
    
    % 处理零和列
    if col_sum == 0
        E(j) = 1; % 熵值最大
        continue;
    end
    
    entropy_sum = 0;
    for i = 1:m
        p_ij = normalized_data(i, j) / col_sum;
        % 处理p_ij=0的情况
        if p_ij > 0
            entropy_sum = entropy_sum + p_ij * log(p_ij);
        end
    end
    E(j) = -1/log(m) * entropy_sum;
end

%% 计算权重
G = 1 - E; % 差异系数
weights = G / sum(G); % 权重归一化

%% 显示结果
fprintf('\n===== 熵权法计算结果 =====\n');
fprintf('指标  熵值      差异系数    权重\n');
for j = 1:n
    fprintf('%2d    %.4f    %.4f    %.4f\n', j, E(j), G(j), weights(j));
end

%% 可视化结果
figure;
subplot(1,2,1);
bar(weights);
title('指标权重分布');
xlabel('指标序号');
ylabel('权重值');
grid on;

subplot(1,2,2);
pie(weights);
title('权重比例分布');
legend(arrayfun(@(x)sprintf('指标%d',x),1:n, 'UniformOutput', false));

% 添加表格形式显示
fprintf('\n权重汇总表:\n');
fprintf('指标序号  权重\n');
for j = 1:n
    fprintf('   %d      %.4f\n', j, weights(j));
end
end
