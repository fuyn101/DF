function [w, CR, lambda_max] = AHP_EigenvectorMethod(A)
% AHP_EigenvectorMethod: 使用特征向量法计算层次分析法(AHP)的权重和一致性。
%
% 输入:
%   A - 成对比较矩阵 (n x n)，必须为方阵。
%
% 输出:
%   w          - 计算得到的权重向量 (n x 1)。
%   CR         - 一致性比例。
%   lambda_max - 矩阵A的最大特征值。
%
% 示例:
%   A = [1, 1, 3, 4; 1, 1, 3, 4; 1/3, 1/3, 1, 3; 1/4, 1/4, 1/3, 1];
%   [w, CR, l_max] = AHP_EigenvectorMethod(A);
%   disp('权重向量:');
%   disp(w');
%   disp(['一致性比例: ', num2str(CR)]);
%   if CR >= 0.1
%       disp('警告: 判断矩阵的一致性较差，请检查输入。');
%   end

% 检查输入是否为方阵
[r, c] = size(A);
if r ~= c
    error('输入矩阵必须是方阵。');
end
n = r;

% 使用特征向量法计算权重
[V, D] = eig(A);
lambda = diag(D);
[lambda_max_val, idx] = max(real(lambda)); % 取实部的最大值
w = real(V(:, idx)); % 对应特征向量
w = w / sum(w);      % 归一化

% 确保返回的lambda_max是实数
lambda_max = real(lambda_max_val);

% 计算一致性指标 (CI)
CI = (lambda_max - n) / (n - 1);

% RI值表，适用于1到9阶矩阵
RI_values = [0, 0, 0.58, 0.90, 1.12, 1.24, 1.32, 1.41, 1.45];
if n > length(RI_values)
    error('矩阵阶数 %d 过大，无对应的RI值。', n);
end
RI = RI_values(n);

% 计算一致性比例 (CR)
if RI == 0
    CR = 0; % 对于1阶和2阶矩阵，总是一致的
else
    CR = CI / RI;
end

end
