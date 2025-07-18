function [Ex, En, He] = CloudModel(data, type, varargin)
% CLOUDMODEL - 云模型操作综合工具箱
% 此函数作为各种云模型功能的分发器。
%
% 用法:
%   [Ex, En, He] = CloudModel(data, 'calculate_parameters')
%   similarity = CloudModel(result_cloud, 'calculate_similarity', standard_cloud)
%   CloudModel(clouds_to_plot, 'plot_clouds', plot_options)
%

switch type
    case 'calculate_parameters'
        % 从数据计算云参数
        [Ex, En, He] = calculate_cloud_parameters(data);
        if nargout == 0
            fprintf('计算出的参数:\n');
            fprintf('期望 Ex: %f\n', Ex);
            fprintf('熵 En: %f\n', En);
            fprintf('超熵 He: %f\n', He);
        end
        
    case 'calculate_similarity'
        % 计算两个云之间的相似度
        result_cloud = data; % 在此情况下, 'data' 是结果云结构体
        standard_cloud = varargin{1};
        Ex = calculate_similarity(result_cloud, standard_cloud); % 使用 Ex 作为相似度的输出
        En = []; He = []; % 未使用
        
    case 'plot_clouds'
        % 绘制一个或多个云
        clouds_to_plot = data; % 在此情况下, 'data' 是云的数组
        plot_options = varargin{1};
        plot_clouds(clouds_to_plot, plot_options);
        Ex = []; En = []; He = []; % 无数值输出
        
    otherwise
        error('指定了无效的操作类型。请使用 ''calculate_parameters'', ''calculate_similarity'', 或 ''plot_clouds''。');
end
end

% ----------------- 本地函数 -----------------

function [Ex, En, He] = calculate_cloud_parameters(data_vector)
% 从数据向量计算云模型的三个数字特征。
% 基于原始 big_cloud.m 的逻辑
if ~isvector(data_vector)
    error('用于参数计算的输入数据必须是单个向量。');
end
Ex = mean(data_vector);
S2 = var(data_vector);
En = sqrt(pi/2) * mean(abs(data_vector - Ex));
He = sqrt(S2 - En^2);
if imag(He) ~= 0 || He < 0
    % 如果方差小于熵的平方，则进行回退计算
    He = 0.01; % 分配一个小的默认值
end
end

function [similarity] = calculate_similarity(result_cloud, standard_cloud)
% 计算结果云与标准云的相似度。
% 基于原始 cloud_TO.m 的逻辑
N = 1000; % 要生成的云滴数

% 从结果云生成N个随机数
En_r = randn(1, N) * result_cloud.He + result_cloud.En;
x_r = randn(1, N) .* En_r + result_cloud.Ex;

% 计算这些数字对标准云的隶属度
membership_degrees = exp(-(x_r - standard_cloud.Ex).^2 ./ (2 * standard_cloud.En^2));

similarity = mean(membership_degrees);
end

function plot_clouds(clouds, options)
% 使用指定选项绘制一个或多个云。
% 结合了 Result.m, Standard.m 等的逻辑。

figure;
hold on;

colors = 'brgcmky'; % 用于不同云的颜色

for i = 1:length(clouds)
    cloud = clouds(i);
    N = 1000; % 云滴数
    
    % 生成云滴
    Enn = randn(1, N) * cloud.He + cloud.En;
    x = randn(1, N) .* Enn + cloud.Ex;
    y = exp(-(x - cloud.Ex).^2 ./ (2 * Enn.^2));
    
    % 绘图
    plot_color = colors(mod(i-1, length(colors)) + 1);
    plot(x, y, '.', 'Color', plot_color);
    
    % 如果提供了文本标签，则添加
    if isfield(cloud, 'Label') && ~isempty(cloud.Label)
        text(cloud.Ex, 1.05, cloud.Label, 'HorizontalAlignment', 'center', 'FontName', 'Microsoft YaHei');
    end
end

% 从选项设置绘图属性
if isfield(options, 'Title')
    title(options.Title);
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

set(gca, 'FontName', 'Microsoft YaHei'); % 设置字体以正确显示中文
box on;
grid on;
hold off;
end
