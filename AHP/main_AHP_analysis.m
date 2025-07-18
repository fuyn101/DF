%% 主脚本：执行层次分析法 (AHP)
% 该脚本演示了如何使用 AHP_EigenvectorMethod 和 AHP_RootMethod 函数
% 来计算权重和进行一致性检验。

clear; clc; close all;

%% 1. 定义判断矩阵
% 这是用户需要根据自己的问题定义的成对比较矩阵。
% 矩阵的阶数 n 决定了有多少个评价指标。
%
% 示例矩阵 (n=4):
% 假设有4个指标 C1, C2, C3, C4
A = [1,   1/3, 2,   4;   % C1 与 C1, C2, C3, C4 的比较
    3,   1,   4,   5;   % C2 与 C1, C2, C3, C4 的比较
    1/2, 1/4, 1,   3;   % C3 与 C1, C2, C3, C4 的比较
    1/4, 1/5, 1/3, 1];  % C4 与 C1, C2, C3, C4 的比较

%% 2. 使用特征向量法进行计算 (推荐方法)
fprintf('--- 1. 特征向量法计算结果 ---\n');
try
    [w_eig, CR_eig, lambda_max] = AHP_EigenvectorMethod(A);
    
    % 显示结果
    fprintf('最大特征值 λ_max: %.4f\n', lambda_max);
    fprintf('权重向量 w:\n');
    disp(w_eig');
    fprintf('一致性比例 CR: %.4f\n', CR_eig);
    
    % 检查一致性
    if CR_eig < 0.1
        fprintf('结果通过一致性检验 (CR < 0.1)。\n');
    else
        fprintf('警告: 未通过一致性检验 (CR >= 0.1)，请检查判断矩阵。\n');
    end
catch ME
    fprintf('计算出错: %s\n', ME.message);
end

%% 3. 使用方根法进行计算 (近似方法)
fprintf('\n--- 2. 方根法计算结果 ---\n');
try
    [w_root, CR_root] = AHP_RootMethod(A);
    
    % 显示结果
    fprintf('权重向量 w:\n');
    disp(w_root');
    fprintf('一致性比例 CR: %.4f\n', CR_root);
    
    % 检查一致性
    if CR_root < 0.1
        fprintf('结果通过一致性检验 (CR < 0.1)。\n');
    else
        fprintf('警告: 未通过一致性检验 (CR >= 0.1)，请检查判断矩阵。\n');
    end
catch ME
    fprintf('计算出错: %s\n', ME.message);
end

%% 4. 结果比较
fprintf('\n--- 3. 两种方法权重结果对比 ---\n');
fprintf('特征向量法: ');
fprintf('%.4f  ', w_eig);
fprintf('\n');
fprintf('方根法:     ');
fprintf('%.4f  ', w_root);
fprintf('\n');
