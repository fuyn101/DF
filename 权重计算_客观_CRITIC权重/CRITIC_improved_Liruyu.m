function [weights, scores, normalized_data] = CRITIC_improved_Liruyu(data, indicator_types)
%improvedCRITIC 使用一种改良的CRITIC方法计算客观权重
%   该函数实现了一种CRITIC方法的变体。与标准CRITIC方法使用“冲突性之和”
%   (sum of 1-r)来量化冲突性不同，本方法使用“1减去平均相关系数”
%   (1 - average r)来衡量指标的冲突性。
%
%   输入参数:
%   data            - 原始决策矩阵 (m x n)，其中 m 是样本数，n 是指标数。
%   indicator_types - 一个 1 x n 的向量，用于指定每个指标的类型：
%                     1  代表正向指标（效益型，值越大越好）。
%                     -1 代表负向指标（成本型，值越小越好）。
%                     如果省略此参数，则默认所有指标均为正向。
%
%   输出参数:
%   weights         - 一个 1 x n 的向量，包含每个指标的改良CRITIC权重。
%   scores          - 一个 m x 1 的向量，包含每个样本的综合得分。
%   normalized_data - 标准化后的决策矩阵。
%
%   使用示例:
%   % 假设有 5 个样本和 4 个指标
%   data = rand(5, 4) * 100;
%   % 假设第1, 2, 4个是正向指标，第3个是负向指标
%   indicator_types = [1, 1, -1, 1];
%   [w, s] = improvedCRITIC(data, indicator_types);
%   disp('计算出的改良CRITIC权重为:');
%   disp(w);

% --- 参数校验 ---
[m, n] = size(data);
if nargin < 2
    % 如果未提供指标类型，则默认所有指标均为正向指标
    indicator_types = ones(1, n);
    disp('未指定指标类型，默认所有指标为正向指标。');
end

if size(indicator_types, 2) ~= n
    error('指标类型向量的长度必须与数据矩阵的列数相等。');
end

% --- 步骤 1: 数据标准化 (与标准方法相同) ---
normalized_data = zeros(m, n);
for j = 1:n
    col_data = data(:, j);
    max_val = max(col_data);
    min_val = min(col_data);
    range_val = max_val - min_val;
    
    if range_val == 0
        % 如果一列中的所有值都相同，则标准化后为0.5，避免分母为零
        normalized_data(:, j) = 0.5;
        continue;
    end
    
    if indicator_types(j) == 1 % 正向指标
        normalized_data(:, j) = (col_data - min_val) / range_val;
    elseif indicator_types(j) == -1 % 负向指标
        normalized_data(:, j) = (max_val - col_data) / range_val;
    else
        error('指标类型向量中只允许包含 1 或 -1。');
    end
end

% --- 步骤 2: 计算对比强度 (Variability) ---
% 对比强度由标准化后数据的标准差表示。
variability = std(normalized_data, 0, 1); % 使用样本标准差

% --- 步骤 3: 计算冲突性 (Conflict) - 此处为改良方法 ---
R = corrcoef(normalized_data); % 计算相关系数矩阵
% 检查R中是否有NaN（当某列标准差为0时可能发生）
if any(isnan(R(:)))
    R(isnan(R)) = 0; % 将NaN替换为0，表示不相关
end

% 计算每个指标与其他指标的平均相关性
% sum(R, 2) 按行求和，得到 n x 1 的列向量
% 减去1是去掉自身与自身的相关性(Rii=1)
% 除以(n-1)得到平均相关系数
avg_corr = (sum(R, 2) - 1) / (n - 1);
conflict_measure = 1 - avg_corr'; % 转置为 1 x n 的行向量

% --- 步骤 4: 计算信息承载量 (Information Content) ---
% 信息量 C 是对比强度和冲突性的乘积。
C = variability .* conflict_measure;

% --- 步骤 5: 计算最终权重 ---
% 将信息量归一化，得到最终的权重。
if sum(C) == 0
    % 如果所有信息量都为0，则平均分配权重
    weights = ones(1, n) / n;
else
    weights = C / sum(C);
end

% --- 步骤 6: 计算综合得分 ---
% 得分由标准化矩阵和权重的加权和得出。
scores = normalized_data * weights';

end
