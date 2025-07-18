% demo_gameTheoryWeighting: 演示如何使用 gameTheoryWeighting 函数

clear; clc; close all;

% --- 1. 准备权重数据 ---
% 从 boyilun.m 中提取的原始权重向量
w1 = [0.114736662, 0.126210328, 0.184784542, 0.138831361, 0.152714497, 0.167985947, 0.114736662]; % 权重向量1
w2 = [0.036360023, 0.219596363, 0.202412458, 0.206322328, 0.203720976, 0.077249696, 0.054338158]; % 权重向量2

% 假设我们还有第三种权重方法作为示例
w3 = [0.15, 0.1, 0.2, 0.15, 0.1, 0.15, 0.15]; % 权重向量3 (示例)

% 将所有权重向量组合成一个矩阵
% 每一行代表一种权重方法
W_matrix_2 = [w1; w2];
W_matrix_3 = [w1; w2; w3];

% --- 2. 调用博弈论组合赋权函数 ---

% 示例1: 两种权重
[W_combined_2, alpha_2] = gameTheoryWeighting(W_matrix_2);

% 示例2: 三种权重
[W_combined_3, alpha_3] = gameTheoryWeighting(W_matrix_3);


% --- 3. 显示结果 ---

disp('--- 两种权重方法的博弈论组合赋权结果 ---');
disp('原始权重向量:');
disp('  w1:');
disp(w1);
disp('  w2:');
disp(w2);
disp('计算出的组合系数 (alpha):');
disp(alpha_2);
disp('最终的组合权重 (W):');
disp(W_combined_2);
disp('权重和:');
disp(sum(W_combined_2));

disp(' ');
disp('--- 三种权重方法的博弈论组合赋权结果 ---');
disp('原始权重向量:');
disp('  w1:');
disp(w1);
disp('  w2:');
disp(w2);
disp('  w3 (示例):');
disp(w3);
disp('计算出的组合系数 (alpha):');
disp(alpha_3);
disp('最终的组合权重 (W):');
disp(W_combined_3);
disp('权重和:');
disp(sum(W_combined_3));
