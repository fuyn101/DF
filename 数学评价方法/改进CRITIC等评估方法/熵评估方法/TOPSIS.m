% 这里假设 Y_ij 和 W_j 已经在工作空间中定义。  

% TOPSIS (Technique for Order Preference by Similarity to Ideal Solution) 的计算过程  

% Y_ij - 标准化矩阵。  

% W_j - 指标权重。  

  

% 示例数据（请替换为您的实际数据）  

Y_ij = [1 2 3; 4 5 6; 7 8 9]; % 假设的标准化矩阵  

W_j = [0.2; 0.3; 0.5];        % 假设的指标权重  

  

[m, n] = size(Y_ij); % m, n 是 Y_ij 的行列数  

  

% 计算加权标准化矩阵 Z_ij  

Z_ij = zeros(m, n); % 初始化空矩阵  

for i = 1:m  

    for j = 1:n  

        Z_ij(i,j) = Y_ij(i,j) * W_j(j);   

    end  

end  

% 计算最优解和最劣解
Imax_j = max(Z_ij, [], 1); % 每列的最大值
Imin_j = min(Z_ij, [], 1); % 每列的最小值

% 初始化矩阵
Dmax_ij = zeros(m, n);
Dmin_ij = zeros(m, n);

% 计算欧氏距离的平方
for i = 1:m
    for j = 1:n
        Dmax_ij(i, j) = (Imax_j(j) - Z_ij(i, j))^2;
        Dmin_ij(i, j) = (Imin_j(j) - Z_ij(i, j))^2;
    end
end

% 计算欧氏距离
Dmax_i = sqrt(sum(Dmax_ij, 2));
Dmin_i = sqrt(sum(Dmin_ij, 2));

% 计算综合评价值
C_i = Dmin_i ./ (Dmax_i + Dmin_i);

% 如果你希望将结果保存到Excel中：
% writematrix(C_i, 'C_i.xls'); % 保存综合评价值到Excel

disp(C_i); % 在控制台打印 C_i

% 如果你希望将其他值（最优解、最劣解）也保存到Excel中，请取消下面两行的注释：
% writematrix(Dmax_i, 'Dmax_i.xls'); % 保存最优解到Excel
% writematrix(Dmin_i, 'Dmin_i.xls'); % 保存最劣解到Excel