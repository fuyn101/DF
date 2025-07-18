clc; clear; close all;

% 读取 Excel 文件
file_path = 'F:\jupyter\karst_data.xlsx'; % Excel 文件路径
data = readmatrix(file_path); % 读取所有数据
x_data = data(:, 2:7); % 选取6个特征（假设第1列是序号）

% 标准范围 [a_ij, b_ij] 和节区域 [c_ij, d_ij]
a_ij = [
    0, 0.02, 0.042, 0.104, 0.254;
    0, 5, 10, 30, 100; 
    0, 300, 600, 900, 1200;
    0, 1, 2, 3, 4; 
    0, 0.1662, 0.2822, 0.4491, 0.5865;
    0, 1, 2, 3, 4; 
];

b_ij = [
    0.02, 0.042, 0.104, 0.254, 1;  
    5, 10, 30, 100, 200; 
    300, 600, 900, 1200, 1500;
    1, 2, 3, 4, 5;
    0.1662, 0.2822, 0.4491, 0.5865, 1;
    1, 2, 3, 4, 5;
];

c_ij = [
    0, 0, 0, 0, 0;  % 指标 1 的节区域下限
    0, 0, 0, 0, 0;
    0, 0, 0, 0, 0;
    0, 0, 0, 0, 0;
    0, 0, 0, 0, 0;
    0, 0, 0, 0, 0;
];

d_ij = [
    1, 1, 1, 1, 1;  % 指标 1 的节区域上限
    200, 200, 200, 200, 200;  
    1500, 1500,  1500, 1500, 1500;
    5, 5, 5, 5, 5;
    1, 1, 1, 1, 1;
    5, 5, 5, 5, 5;
];

% 组合权重
weights = [0.2145, 0.1526, 0.1903, 0.1209, 0.1323, 0.1694]; 

% 数据行数
num_samples = size(x_data, 1);
results = zeros(num_samples, 5); % 存储综合关联度

% 逐行计算关联度
for row = 1:num_samples
    x_j = x_data(row, :);
    K_i_xj = zeros(5, 6); % 5 个等级，6 个指标的关联度矩阵

    for j = 1:6  % 遍历 6 个指标
        for i = 1:5  % 遍历 5 个等级
            rho_xj_xij = abs(x_j(j) - 0.5 * (a_ij(j, i) + b_ij(j, i))) - 0.5 * (b_ij(j, i) - a_ij(j, i));
            rho_xj_Xij = abs(x_j(j) - 0.5 * (c_ij(j, i) + d_ij(j, i))) - 0.5 * (d_ij(j, i) - c_ij(j, i));

            if x_j(j) >= a_ij(j, i) && x_j(j) <= b_ij(j, i)
                K_i_xj(i, j) = rho_xj_xij / abs((b_ij(j, i) - a_ij(j, i)));
            else
                K_i_xj(i, j) = rho_xj_xij / (rho_xj_xij - rho_xj_Xij);
            end
        end
    end
 % 显示每个钻孔的 K_i_xj 关联矩阵
    fprintf('钻孔 %d 的 K_i_xj 关联矩阵:\n', row);
    disp(K_i_xj);

    % 计算加权综合关联度
    weighted_K = K_i_xj .* weights;
    comprehensive_K = sum(weighted_K, 2);
    results(row, :) = comprehensive_K';
end

% 将结果保存到 Excel
output_file = 'F:\jupyter\result.xlsx';
header = {'等级1', '等级2', '等级3', '等级4', '等级5'};
output_data = [header; num2cell(results)];
writecell(output_data, output_file);

disp(['计算完成，结果已保存至: ', output_file]);
