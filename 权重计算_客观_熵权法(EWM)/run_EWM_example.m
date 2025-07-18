% --- EntropyWeightMethod 函数使用示例脚本 ---

%% 1. 清理工作区和命令窗口
clear;
clc;
close all;

%% 2. 定义输入数据
% 示例数据矩阵 (m个样本 x n个指标)
data = [82, 89, 70;
    75, 80, 85;
    90, 85, 75];

% 定义哪些列是负向指标 (值越小越好)
% 在本例中, 第3个指标是负向指标
negative_cols = [3];

%% 3. 调用熵权法函数
[weights, normalized_data] = EntropyWeightMethod(data, negative_cols);

%% 4. 显示结果
fprintf('\n===== 熵权法计算结果 =====\n');
fprintf('指标权重:\n');
disp(weights);

fprintf('\n标准化后的数据矩阵:\n');
disp(normalized_data);

% 详细的权重表格
fprintf('\n--- 权重详细摘要 ---\n');
fprintf('指标   权重\n');
fprintf('--------------------------\n');
for i = 1:length(weights)
    fprintf('   %d      %.4f\n', i, weights(i));
end
fprintf('--------------------------\n');

%% 5. 可视化结果
visualize_EWM_weights(weights);
