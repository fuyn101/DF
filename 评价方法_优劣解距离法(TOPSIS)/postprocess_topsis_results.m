function postprocess_topsis_results(X_data, scores, model_name)
% postprocess_topsis_results: 对TOPSIS结果进行可视化和导出
%
% 输入:
%   X_data     - 原始数据矩阵 (m x n)
%   scores     - 计算出的综合评价值 (m x 1)
%   model_name - 模型名称字符串 (例如, '极差归一化'), 用于图表标题和文件名

% --- 准备数据 ---
[sorted_scores, sort_order] = sort(scores, 'descend');

% 计算每个对象的最终排名
ranks = zeros(size(scores));
ranks(sort_order) = 1:length(scores);

% --- 1. 可视化：生成排序柱状图 ---
figure; % 创建新图形窗口
barh(1:length(sorted_scores), sorted_scores, 'FaceColor', [0.2 0.6 0.8]); % 创建水平条形图

% 设置字体为宋体 (确保您的系统已安装宋体)
set(gca, 'FontName', 'SimSun', 'FontSize', 10);

% 设置标题和标签
chart_title = sprintf('TOPSIS 综合评价结果 (%s)', model_name);
title(chart_title, 'FontName', 'SimSun', 'FontSize', 14, 'FontWeight', 'bold');
xlabel('综合评价值 C_i', 'FontName', 'SimSun', 'FontSize', 12);
ylabel('评价对象', 'FontName', 'SimSun', 'FontSize', 12);

% 设置Y轴刻度标签，显示为 "对象 X"
set(gca, 'YTick', 1:length(sorted_scores), 'YTickLabel', arrayfun(@(x) sprintf('对象 %d', x), sort_order, 'UniformOutput', false));
set(gca, 'YDir', 'reverse'); % 将Y轴反转，使第一名在最上方

% 为每个条形图添加数据标签
for i = 1:length(sorted_scores)
    text(sorted_scores(i), i, sprintf(' %.4f', sorted_scores(i)), ...
        'VerticalAlignment', 'middle', 'HorizontalAlignment', 'left', 'FontName', 'SimSun');
end
grid on;
fprintf('已为“%s”模型生成排序柱状图。\n', model_name);

% --- 2. 导出：生成CSV文件 ---
num_objects = size(X_data, 1);
num_indicators = size(X_data, 2);
object_ids = (1:num_objects)';

% 创建动态变量名
var_names = {'对象ID'};
for i = 1:num_indicators
    var_names{end+1} = sprintf('指标%d', i);
end
var_names = [var_names, {'综合得分', '排名'}];

% 创建包含所有相关数据的表格
% 错误修复：MATLAB的table函数不能直接接受一个多列矩阵(X_data)和多个单列向量来匹配一个扁平的变量名列表。
% 正确的做法是先将所有数据列合并成一个单独的矩阵，然后使用array2table进行转换。
all_data_matrix = [object_ids, X_data, scores, ranks];
results_table = array2table(all_data_matrix, 'VariableNames', var_names);

% 对表格按“排名”列升序排序
sorted_results_table = sortrows(results_table, '排名', 'ascend');

% 定义输出文件名并导出
output_filename = sprintf('topsis_results_%s.csv', strrep(model_name, ' ', '_'));
try
    writetable(sorted_results_table, output_filename, 'Encoding', 'UTF-8');
    fprintf('已将“%s”模型的排序结果导出到 %s 文件中。\n', model_name, output_filename);
catch ME
    fprintf('导出CSV文件失败。错误信息: %s\n', ME.message);
    fprintf('尝试使用不带编码的格式导出...\n');
    try
        writetable(sorted_results_table, output_filename);
        fprintf('已成功导出到 %s (无特定编码)。\n', output_filename);
    catch ME2
        fprintf('无编码格式导出也失败了。错误信息: %s\n', ME2.message);
    end
end

end
