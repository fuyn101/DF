function [w, Score] = CoVM(data, index)
% CoVM: 使用变异系数法计算权重和得分
%
% 输入:
%   data  - 原始数据矩阵 (m x n, m个样本, n个指标)
%   index - 负向指标的列索引 (可选, 默认为空)
%
% 输出:
%   w     - 计算出的权重向量 (1 x n)
%   Score - 每个样本的百分制得分 (m x 1)

% 默认负向指标为空
if nargin < 2
    index = [];
end

% 1. 指标正向化处理
data1 = data;
k = 0.1; % 正向化参数
if ~isempty(index)
    for i = 1:length(index)
        col = index(i);
        data1(:, col) = 1 ./ (k + max(abs(data(:, col))) + data(:, col));
    end
end

% 2. 数据标准化 (向量归一化)
data2 = data1;
for j = 1:size(data1, 2)
    data2(:, j) = data1(:, j) ./ sqrt(sum(data1(:, j).^2));
end

% 3. 计算变异系数
A = mean(data2); % 求每列平均值
S = std(data2);  % 求每列标准差
V = S ./ A;      % 计算变异系数

% 4. 计算权重
w = V ./ sum(V); % 归一化得到权重

% 5. 计算得分
s = data2 * w';
Score = 100 * s / max(s); % 百分制得分

end
