function visualize_results(w, Score)
% visualize_results: 可视化变异系数法的结果
%
% 输入:
%   w     - 指标权重向量 (1 x n)
%   Score - 评价对象的得分向量 (m x 1)

% 1. 可视化权重
figure;
bar(w);
title('变异系数法计算的指标权重', 'FontName', 'SimSun');
xlabel('指标', 'FontName', 'SimSun');
ylabel('权重', 'FontName', 'SimSun');
set(gca, 'FontName', 'SimSun', 'XTickLabel', sprintfc('指标%d', 1:length(w)));

% 2. 可视化得分
figure;
bar(Score);
title('各评价对象的百分制得分', 'FontName', 'SimSun');
xlabel('样本', 'FontName', 'SimSun');
ylabel('得分', 'FontName', 'SimSun');
set(gca, 'FontName', 'SimSun', 'XTickLabel', sprintfc('样本%d', 1:length(Score)));

end
