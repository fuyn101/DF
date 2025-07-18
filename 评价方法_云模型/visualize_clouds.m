function visualize_clouds(clouds, options)
% VISUALIZE_CLOUDS - 使用指定选项绘制一个或多个云模型。
%
% 用法:
%   visualize_clouds(clouds, options)
%
% 输入:
%   clouds  - 一个结构体数组，每个结构体代表一个云，需要包含
%             字段 Ex, En, He。可选字段: Label。
%   options - 一个结构体，包含绘图选项，如:
%             Title, XLabel, YLabel, Axis。

figure;
hold on;

colors = 'brgcmky'; % 用于不同云的颜色

for i = 1:length(clouds)
    cloud = clouds(i);
    N = 1000; % 每个云生成的云滴数
    
    % 检查必需的字段是否存在
    if ~isfield(cloud, 'Ex') || ~isfield(cloud, 'En') || ~isfield(cloud, 'He')
        error('输入云结构体 #%d 缺少 Ex, En, 或 He 字段。', i);
    end
    
    % 生成云滴
    Enn = randn(1, N) * cloud.He + cloud.En;
    x = randn(1, N) .* Enn + cloud.Ex;
    y = exp(-(x - cloud.Ex).^2 ./ (2 * Enn.^2));
    
    % 绘图
    plot_color = colors(mod(i-1, length(colors)) + 1);
    plot(x, y, '.', 'Color', plot_color);
    
    % 如果提供了文本标签，则添加
    if isfield(cloud, 'Label') && ~isempty(cloud.Label)
        text(cloud.Ex, 1.05, cloud.Label, 'HorizontalAlignment', 'center', 'FontName', 'SimSun', 'FontSize', 12);
    end
end

% 从选项设置绘图属性
if isfield(options, 'Title')
    title(options.Title, 'FontSize', 14);
end
if isfield(options, 'XLabel')
    xlabel(options.XLabel);
end
if isfield(options, 'YLabel')
    ylabel(options.YLabel);
end
if isfield(options, 'Axis')
    axis(options.Axis);
end

set(gca, 'FontName', 'SimSun'); % 设置字体以正确显示中文
box on;
grid on;
hold off;
end
