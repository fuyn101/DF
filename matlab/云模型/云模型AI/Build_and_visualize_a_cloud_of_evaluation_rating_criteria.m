% =========================================================================
%               生成阻隔水性能评价等级标准云图
%
% 功能: 
%   1. 根据设定的评价等级、论域区间和公式，计算标准云的数字特征。
%   2. 使用正向云发生器为每个等级生成云滴。
%   3. 将所有标准云绘制在同一张图上，作为后续评价的“标尺”。
%
% 作者: AI助手 (根据您的需求定制)
% 日期: 2023-10-27
% =========================================================================

%% 1. 初始化设置
clear;         % 清空工作区变量
clc;           % 清空命令行窗口
close all;     % 关闭所有图形窗口
format short;  % 设置数据显示格式

%% 2. 定义评价等级和标准云参数
% 定义评价等级的论域区间 [C_min, C_max]
% 您可以根据您的专业知识微调这些区间
intervals = {
    [90, 100];  % I级 (好)
    [75, 90];   % II级 (较好)
    [60, 75];   % III级 (一般)
    [0, 60]     % IV级 (差)
};

% 定义等级标签
labels = {'I级 (好)', 'II级 (较好)', 'III级 (一般)', 'IV级 (差)'};

% 定义每个等级的超熵 He (通常设为一个较小的常数)
He_val = 0.1;

% 使用结构体数组来存储每个标准云的参数
num_levels = length(labels);
standard_clouds = struct('Ex', cell(1, num_levels), ...
                         'En', cell(1, num_levels), ...
                         'He', cell(1, num_levels), ...
                         'Label', cell(1, num_levels));
                     
% 循环计算每个标准云的 Ex, En, He
disp('计算得到的评价等级标准云参数:');
disp('----------------------------------------------------');
disp('等级      Ex       En         He');
disp('----------------------------------------------------');
for i = 1:num_levels
    C_min = intervals{i}(1);
    C_max = intervals{i}(2);
    
    % 根据公式计算 Ex 和 En
    standard_clouds(i).Ex = (C_min + C_max) / 2;
    standard_clouds(i).En = (C_max - C_min) / 6;
    standard_clouds(i).He = He_val;
    standard_clouds(i).Label = labels{i};
    
    % 在命令行窗口显示计算结果
    fprintf('%-8s  %6.2f   %6.3f   %6.3f\n', ...
            standard_clouds(i).Label, ...
            standard_clouds(i).Ex, ...
            standard_clouds(i).En, ...
            standard_clouds(i).He);
end
disp('----------------------------------------------------');


%% 3. 生成并绘制标准云图
% 设置绘图参数
num_drops = 3000; % 每个云生成的云滴数量，3000个点足够清晰
colors = {  [0.4660 0.6740 0.1880], ... % I级 (优秀) - 绿色
            [0.0000 0.4470 0.7410], ... % II级 (良好) - 蓝色
            [0.9290 0.6940 0.1250], ... % III级 (一般) - 黄色
            [0.8500 0.3250 0.0980]};   % IV级 (差) - 橙红色
       
% 创建一个新的图形窗口
figure('Name', '阻隔水性能评价等级标准云图', 'Position', [100, 100, 800, 600]);
hold on; % 允许在同一张图上叠加绘制

% 循环为每个等级生成云滴并绘制
for i = 1:num_levels
    % 从结构体中获取当前云的参数
    Ex = standard_clouds(i).Ex;
    En = standard_clouds(i).En;
    He = standard_clouds(i).He;
    
    % --- 正向云发生器核心算法 ---
    % 1. 生成以 En 为期望、He 为标准差的正态随机数 En'
    En_prime = normrnd(En, He, 1, num_drops);
    % 熵必须为非负数, 对于理论上可能出现的负值进行处理
    En_prime(En_prime < 0) = 0; 
    
    % 2. 生成以 Ex 为期望、En' 为标准差的正态随机数 x (云滴的x坐标)
    x_drops = normrnd(Ex, En_prime, 1, num_drops);
    
    % 3. 计算每个云滴的隶属度 y (云滴的y坐标)
    y_drops = exp(-(x_drops - Ex).^2 ./ (2 * En_prime.^2));
    
    % 绘制散点图
    scatter(x_drops, y_drops, 10, ...
            'filled', ...
            'MarkerFaceColor', colors{i}, ...
            'MarkerFaceAlpha', 0.4); % 设置透明度，让云图更有层次感
end

%% 4. 美化图形
title('阻隔水性能评价等级标准云图', 'FontSize', 16, 'FontWeight', 'bold');
xlabel('评价综合得分 S', 'FontSize', 12);
ylabel('隶属度 μ', 'FontSize', 12);
legend(labels, 'Location', 'northeast', 'FontSize', 10);
grid on; % 添加网格线
box on;  % 添加边框
set(gca, 'FontSize', 11); % 设置坐标轴字体大小
xlim([0, 100]); % 设置X轴范围
ylim([0, 1.1]);  % 设置Y轴范围，留出顶部空间

hold off; % 结束在当前图上的绘制

fprintf('\n标准云图已生成！\n');

