%% --- 云模型评价示例 ---
% 本脚本演示如何使用 CloudModel 工具箱来执行一个完整的评价流程。

clear; clc; close all;

%% 1. 定义标准评价等级
% 定义代表评价等级的标准云的参数。
% (这些值取自原始的 Standard.m 文件)
fprintf('第1步: 定义标准评价等级...\n');
standards(1) = struct('Ex', 0.8919, 'En', 0.07207, 'He', 0.01, 'Label', '优秀');
standards(2) = struct('Ex', 0.5919, 'En', 0.12793, 'He', 0.01, 'Label', '良好');
standards(3) = struct('Ex', 0.2655, 'En', 0.08967, 'He', 0.01, 'Label', '中等');
standards(4) = struct('Ex', 0.0655, 'En', 0.04367, 'He', 0.01, 'Label', '较差');
fprintf('完成。\n\n');

%% 2. 生成用于评价的样本数据
% 在实际场景中，这些数据将来自您的测量或调查。
% 这里，我们生成一些样本数据用于演示。
fprintf('第2步: 为待评价项生成样本数据...\n');
% 假设我们的项目介于“良好”和“优秀”之间
sample_data = 0.7 + 0.1 * randn(10000, 1);
fprintf('完成。\n\n');

%% 3. 为样本数据计算云参数
fprintf('第3步: 为样本数据计算云模型参数...\n');
[Ex, En, He] = CloudModel(sample_data, 'calculate_parameters');
result_cloud = struct('Ex', Ex, 'En', En, 'He', He, 'Label', '评价结果');
fprintf('计算完成:\n');
fprintf('  - 期望 Ex: %f\n', Ex);
fprintf('  - 熵 En: %f\n', En);
fprintf('  - 超熵 He: %f\n', He);
fprintf('\n');

%% 4. 通过计算相似度确定评价等级
fprintf('第4步: 计算与每个标准等级的相似度...\n');
similarities = zeros(1, length(standards));
for i = 1:length(standards)
    similarities(i) = CloudModel(result_cloud, 'calculate_similarity', standards(i));
    fprintf('  - 与“%s”的相似度: %f\n', standards(i).Label, similarities(i));
end

[max_similarity, best_match_index] = max(similarities);
final_level = standards(best_match_index).Label;

fprintf('\n评价结果:\n');
fprintf('最终评价等级为“%s”，相似度为 %f。\n\n', final_level, max_similarity);

%% 5. 可视化结果
fprintf('第5步: 生成可视化图表...\n');
% 结合结果云和标准云以便绘图
all_clouds = [result_cloud, standards];

% 定义绘图选项
plot_options = struct(...
    'Title', '云模型评价结果', ...
    'XLabel', '评价值', ...
    'YLabel', '隶属度', ...
    'Axis', [0, 1, 0, 1.2]);

% 调用新的独立绘图函数
visualize_clouds(all_clouds, plot_options);
fprintf('图表已生成。请检查新的图形窗口。\n');
