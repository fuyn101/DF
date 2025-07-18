function [w, CR] = AHP_RootMethod(A)
% AHP_RootMethod: 使用方根法计算层次分析法(AHP)的权重和一致性比例。
%
% 输入:
%   A - 成对比较矩阵 (n x n)，必须为方阵。
%
% 输出:
%   w  - 计算得到的权重向量 (n x 1)。
%   CR - 一致性比例。
%
% 示例:
%   A = [1, 2, 3; 1/2, 1, 4; 1/3, 1/4, 1];
%   [w, CR] = AHP_RootMethod(A);
%   disp('权重向量:');
%   disp(w');
%   disp(['一致性比例: ', num2str(CR)]);

% 检查输入是否为方阵
[r, c] = size(A);
if r ~= c
    error('输入矩阵必须是方阵。');
end
n = r;

% 计算每个准则的权重（方根法）
w = zeros(n, 1);
for i = 1:n
    w(i) = prod(A(i,:))^(1/n);
end
w = w / sum(w);

% 计算一致性比例
lambda_max = max(eig(A));
CI = (lambda_max - n) / (n - 1);

% RI值表，适用于1到9阶矩阵
RI_values = [0, 0, 0.58, 0.90, 1.12, 1.24, 1.32, 1.41, 1.45];
if n > length(RI_values)
    error('矩阵阶数过大，无对应的RI值。');
end
RI = RI_values(n);

if RI == 0
    CR = 0; % 对于1阶和2阶矩阵，总是一致的
else
    CR = CI / RI;
end

end
