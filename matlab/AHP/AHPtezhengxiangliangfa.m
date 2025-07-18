A = [1, 1, 3, 4, 3, 7;
     1, 1, 3, 4, 3, 7;
     1/3, 1/3, 1,3, 4, 5;
     1/4, 1/4, 1/3, 1, 1, 6;
     1/3, 1/3, 1/4, 1, 1, 5;
     1/7, 1/7, 1/5,1/6, 1/5, 1;];  % 您的判断矩阵

% ===== 修正1：使用特征向量法计算权重 =====
[V, D] = eig(A);
lambda = diag(D);
[lambda_max, idx] = max(real(lambda));  % 取实部的最大值
w = real(V(:, idx));  % 对应特征向量
w = w / sum(w);       % 归一化

% ===== 修正2：正确获取RI值 =====
n = size(A, 1);
RI_values = [0, 0, 0.58, 0.90, 1.12, 1.24, 1.32, 1.41, 1.45]; 
RI = RI_values(n);  % 直接按阶数取值

% ===== 修正3：确保使用实数计算 =====
CI = (real(lambda_max) - n) / (n - 1);  % 取实部
CR = CI / RI;

% 输出结果
fprintf('修正后的权重 w:\n');
disp(w');
fprintf('最大特征值 λ_max: %.6f\n', real(lambda_max));
fprintf('一致性指标 CI: %.6f\n', CI);
fprintf('一致性比例 CR: %.6f\n', CR);