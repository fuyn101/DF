function [w, CR, lambda_max] = AHP_RootMethod(A)
% AHP_RootMethod: 使用方根法计算层次分析法(AHP)的权重和一致性。
%
% Input:
%   A - 判断矩阵 (n x n)，必须为正互反矩阵。
%
% Output:
%   w          - 计算得到的权重向量 (n x 1)。
%   CR         - 一致性比例 (Consistency Ratio)。
%   lambda_max - 判断矩阵A的最大特征值 (用于一致性检验)。
%
% Example:
%   A = [1, 2, 3; 1/2, 1, 4; 1/3, 1/4, 1];
%   [w, CR, lambda_max] = AHP_RootMethod(A);
%   disp('权重向量 (w):');
%   disp(w');
%   disp(['最大特征值 (lambda_max): ', num2str(lambda_max)]);
%   disp(['一致性比例 (CR): ', num2str(CR)]);
%   if CR >= 0.1
%       disp('警告: 判断矩阵的一致性不满足要求，请重新调整判断矩阵。');
%   else
%       disp('判断矩阵通过一致性检验。');
%   end

% 检查输入矩阵是否为方阵
[rows, cols] = size(A);
if rows ~= cols
    error('输入矩阵A必须是方阵。');
end
n = rows;

% --- 1. 使用方根法计算权重 ---
w_temp = zeros(n, 1);
for i = 1:n
    w_temp(i) = prod(A(i,:))^(1/n);
end
w = w_temp / sum(w_temp);

% --- 2. 一致性检验 ---
% 计算最大特征值 lambda_max
lambda_max = real(max(eig(A))); % 取实部确保结果可靠

% 计算一致性指标 (CI)
CI = (lambda_max - n) / (n - 1);

% RI值表 (适用于1到9阶矩阵)
RI_table = [0, 0, 0.58, 0.90, 1.12, 1.24, 1.32, 1.41, 1.45];
if n > length(RI_table)
    error('矩阵阶数 n=%d 过大，无对应的RI值。请检查RI_table。', n);
end
RI = RI_table(n);

% 计算一致性比例 (CR)
if RI == 0
    CR = 0; % 对于1阶和2阶矩阵，总是一致的
else
    CR = CI / RI;
end

end
