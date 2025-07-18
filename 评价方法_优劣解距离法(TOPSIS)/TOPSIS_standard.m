function [C_i, Dmax_i, Dmin_i] = TOPSIS_standard(X, W_j, indicator_type)
% TOPSIS_standard: 使用TOPSIS方法计算综合评价值（采用向量归一化）
%
% 输入:
%   X              - 原始数据矩阵 (m x n)，m个评价对象, n个评价指标
%   W_j            - 指标权重向量 (1 x n 或 n x 1)
%   indicator_type - 指标类型向量 (1 x n)，1表示正向指标, -1表示负向指标
%
% 输出:
%   C_i    - 每个评价对象的综合评价值 (m x 1)
%   Dmax_i - 每个评价对象与最优解的距离 (m x 1)
%   Dmin_i - 每个评价对象与最劣解的距离 (m x 1)

[m, n] = size(X); % m, n 是 X 的行列数

% 步骤1: 指标正向化
% 对于负向指标，进行正向化处理
X_forward = X;
for j = 1:n
    if indicator_type(j) == -1 % 负向指标 (成本型)
        col_data = X(:, j);
        max_val = max(col_data);
        % 使用 max-x 的方法进行正向化
        X_forward(:, j) = max_val - col_data;
        % 如果需要使用 1/x 的方法，请确保没有0值
        % X_forward(:, j) = 1 ./ col_data;
    elseif indicator_type(j) ~= 1
        error('指标类型向量 (indicator_type) 只能包含 1 或 -1');
    end
end

% 步骤2: 向量归一化
Y_ij = zeros(m, n);
for j = 1:n
    col_norm = norm(X_forward(:, j));
    if col_norm ~= 0
        Y_ij(:, j) = X(:, j) / col_norm;
    else
        Y_ij(:, j) = 0; % 如果列全为0，则归一化后也为0
    end
end

% 步骤3: 计算加权标准化矩阵 Z_ij
Z_ij = Y_ij .* repmat(W_j(:)', m, 1); % 使用矩阵运算提高效率

% 步骤4: 计算最优解和最劣解
% 由于所有指标都已正向化，直接取最大值为最优，最小值为最劣
Imax_j = max(Z_ij, [], 1);
Imin_j = min(Z_ij, [], 1);

% 初始化矩阵
Dmax_ij = zeros(m, n);
Dmin_ij = zeros(m, n);

% 步骤5: 计算欧氏距离
% 使用矩阵运算提高效率
Dmax_i = sqrt(sum((Z_ij - repmat(Imax_j, m, 1)).^2, 2));
Dmin_i = sqrt(sum((Z_ij - repmat(Imin_j, m, 1)).^2, 2));

% 步骤6: 计算综合评价值
C_i = Dmin_i ./ (Dmax_i + Dmin_i);

% 处理分母为0的情况
C_i(isnan(C_i)) = 0;

end

% % ================= 调用示例 =================
% % 如果需要测试该函数，可以取消下面的注释并运行此脚本
%
% % 示例数据
% % 假设有4个评价对象和3个指标
% X_test = [88 85 12;   % 对象1
%           92 90 15;   % 对象2
%           75 80 10;   % 对象3
%           80 95 18];  % 对象4
%
% % 指标权重
% W_test = [0.4, 0.3, 0.3];
%
% % 指标类型: 第1、2个是正向指标(越大越好)，第3个是负向指标(越小越好)
% indicator_type_test = [1, 1, -1];
%
% % 调用函数
% [C, D_max, D_min] = TOPSIS_standard(X_test, W_test, indicator_type_test);
%
% % 显示结果
% disp('综合评价值 C_i:');
% disp(C);
% disp('与最优解的距离 Dmax_i:');
% disp(D_max);
% disp('与最劣解的距离 Dmin_i:');
% disp(D_min);
%
% % 结果排序
% [sorted_C, index] = sort(C, 'descend');
% disp('评价对象排序 (从优到劣):');
% disp(index);
