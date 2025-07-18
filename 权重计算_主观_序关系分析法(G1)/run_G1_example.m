% run_G1_example.m
% 这是一个示例脚本, 用于演示如何调用 G1 函数来计算主观权重。

clear;
clc;

disp('===== 使用 G1 函数计算主观权重示例 =====');

% --- 用户定义参数 ---
% 假设我们有4个评价指标, 分别编号为 1, 2, 3, 4。

% 1. 定义指标的重要性排序 (编码确定排序)
% 专家根据经验判断, 得出重要性排序为: 指标3 > 指标1 > 指标4 > 指标2
% 我们将这个排序编码为向量:
rankOrder = [3, 1, 4, 2];
fprintf('指标重要性排序 (rankOrder): %s\n', mat2str(rankOrder));

% 2. 定义相邻指标的重要性比值
% r_k = w_{k-1} / w_k, 表示第 k-1 重要的指标与第 k 重要的指标的重要性之比。
% r(2): 指标3 vs 指标1 (rankOrder(1) vs rankOrder(2))
% r(3): 指标1 vs 指标4 (rankOrder(2) vs rankOrder(3))
% r(4): 指标4 vs 指标2 (rankOrder(3) vs rankOrder(4))
% 假设专家给出的比值为:
r_values = [1.2, 1.1, 1.3]; % [r2, r3, r4]
fprintf('相邻指标重要性比值 (r_values): %s\n', mat2str(r_values));
disp(' ');

% --- 调用 G1 函数 ---
try
    % 调用 G1.m 函数来计算权重
    weights = G1(rankOrder, r_values);
    
    % --- 显示结果 ---
    disp('计算完成。');
    disp('最终的主观权重向量 (w_subjective):');
    disp(weights);
    
    % 为了更清晰地展示每个指标对应的权重,我们可以创建一个表格
    indicator_names = {'指标1', '指标2', '指标3', '指标4'};
    results_table = table(indicator_names', weights', 'VariableNames', {'指标', '权重'});
    disp('各指标权重详情:');
    disp(results_table);
    
catch ME
    % 捕获并显示可能发生的错误
    fprintf('计算过程中发生错误:\n');
    disp(ME.message);
end
