function visualize_gra_weights(weights)
% visualize_gra_weights - 可视化灰色关联分析(GRA)的指标权重
%
%   输入:
%       weights - 指标权重向量

figure;
bar(weights);
title('灰色关联分析 (GRA) - 指标权重', 'FontName', '宋体');
xlabel('指标序号', 'FontName', '宋体');
ylabel('权重值', 'FontName', '宋体');
grid on;
set(gca, 'XTickLabel', sprintfc('指标 %d', 1:length(weights)), 'FontName', '宋体');
end
