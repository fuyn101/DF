function [weights, gamma] = GRA(data, indicator_types, ro)
% calculate_gra_weights: 使用灰色关联分析法 (GRA) 计算权重
%
% 输入:
%   data            - 原始数据矩阵 (m x n), m 个样本, n 个指标
%   indicator_types - 指标类型向量 (1 x n), 1 表示正向(效益型), -1 表示负向(成本型)
%   ro              - 分辨系数 (可选, 默认为 0.5)
%
% 输出:
%   weights         - 各指标的权重 (1 x n)
%   gamma           - 各指标的灰色关联度 (1 x n)

% --- 1. 输入参数检查 ---
if nargin < 2
    error('至少需要输入数据矩阵和指标类型向量。');
end
if nargin < 3
    ro = 0.5; % 如果未提供分辨系数，则默认为 0.5
end

[m, n] = size(data);
if length(indicator_types) ~= n
    error('指标类型向量的长度必须与数据矩阵的列数相等。');
end

% --- 2. 指标正向化 ---
% 将所有指标统一为正向（效益型）指标
positive_data = data;
for i = 1:n
    if indicator_types(i) == -1 % 如果是负向指标
        col = data(:, i);
        % 使用 min-max 逆转法进行转换
        % (max(x) - x) / (max(x) - min(x))
        % 这种方法可以避免负数或0值问题，并且结果在[0,1]区间
        if max(col) ~= min(col)
            positive_data(:, i) = (max(col) - col) / (max(col) - min(col));
        else
            % 如果一列中的所有值都相同，则转换后它们没有差异，可以设为0或1
            positive_data(:, i) = ones(m, 1);
        end
    end
end

% --- 3. 数据预处理（无量纲化） ---
% 为了避免正向化后出现0值导致均值法出错，这里采用更稳健的 min-max 归一化
% (x - min(x)) / (max(x) - min(x))
normalized_data = zeros(m, n);
for i = 1:n
    col = positive_data(:, i);
    if max(col) ~= min(col)
        normalized_data(:, i) = (col - min(col)) / (max(col) - min(col));
    else
        normalized_data(:, i) = ones(m, 1);
    end
end


% --- 4. 确定参考序列 (理想最优序列) ---
% 将预处理后的矩阵每一行的最大值取出，作为参考序列
Y = max(normalized_data, [], 2);

% --- 5. 计算关联系数 ---
% 计算每个指标序列与参考序列的绝对差
Y_rep = repmat(Y, 1, n);
diff_matrix = abs(normalized_data - Y_rep);

% 计算全局最大差和最小差
min_diff = min(min(diff_matrix));
max_diff = max(max(diff_matrix));

% 计算关联系数矩阵
rel_coeffs = (min_diff + ro * max_diff) ./ (diff_matrix + ro * max_diff);

% --- 6. 计算灰色关联度 ---
% 关联度是每个指标（列）的关联系数的平均值
gamma = mean(rel_coeffs, 1);

% --- 7. 计算权重 ---
% 对关联度进行归一化，得到最终权重
weights = gamma ./ sum(gamma);

end
