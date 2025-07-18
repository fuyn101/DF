function visualize_EWM_weights(weights)
% visualize_EWM_weights - 可视化熵权法计算的权重结果
%
% 语法: visualize_EWM_weights(weights)
%
% 输入:
%   weights - 1 x n 的权重向量

%% 1. 创建图形窗口
figure('Name', '熵权法计算结果');

%% 2. 绘制权重的条形图
subplot(1, 2, 1);
bar(weights);
title('指标权重分布');
xlabel('指标序号');
ylabel('权重值');
grid on;
set(gca, 'XTick', 1:length(weights));
set(gca, 'FontName', '宋体'); % 设置字体为宋体

%% 3. 绘制权重的饼图
subplot(1, 2, 2);
% 为饼图创建标签
labels = arrayfun(@(x) sprintf('指标 %d', x), 1:length(weights), 'UniformOutput', false);
h_pie = pie(weights, labels);
title('权重比例');
legend('Location', 'best');
set(gca, 'FontName', '宋体'); % 设置坐标轴字体

% --- 修正饼图标签字体 ---
% pie函数返回的句柄中，奇数项是patch对象，偶数项是text对象
text_objects = h_pie(2:2:end); % 提取所有text对象的句柄
for i = 1:length(text_objects)
    set(text_objects(i), 'FontName', '宋体');
end

end
