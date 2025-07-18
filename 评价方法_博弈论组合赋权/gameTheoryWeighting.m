function [W, alpha] = gameTheoryWeighting(W_matrix)
% gameTheoryWeighting: 使用博弈论计算组合权重
%
% 输入:
%   W_matrix: 一个 n x m 的矩阵, 其中 n 是权重方法的数量, m 是指标的数量。
%             每一行代表一种方法计算出的权重向量。
%
% 输出:
%   W: 组合后的权重向量 (1 x m)。
%   alpha: 各种权重方法的线性组合系数 (1 x n)。

% 检查输入是否有效
if nargin < 1
    error('需要输入一个权重矩阵。');
end
if isempty(W_matrix)
    error('输入的权重矩阵不能为空。');
end

% 获取权重方法的数量
n = size(W_matrix, 1);

% 构建博弈矩阵 P
P = W_matrix * W_matrix';

% 构建右侧向量 Q
% Q 的对角线元素是 W_matrix * W_matrix' 的对角线元素
Q = diag(P);

% 求解线性方程组 P * alpha' = Q
% alpha' = P \ Q
% alpha = (P \ Q)'
alpha_unnormalized = (P \ Q)';

% 归一化组合系数
alpha_sum = sum(alpha_unnormalized);
alpha = alpha_unnormalized / alpha_sum;

% 计算最终的组合权重
W = alpha * W_matrix;

end
