%% 多评价指标下的云模型分类
% Author: Cline (Generated based on cloud_demo1, cloud_demo3)
% QQ/V: 472770120
%
% --- 脚本功能 ---
% 1. 定义代表不同评价等级的标准二维云模型。
% 2. 输入一个或多个待分类的样本数据（每个样本包含两个指标值）。
% 3. 对每个样本，计算其属于各个等级云的隶属度。
% 4. 根据最大隶属度原则，判断每个样本的最终等级。
% 5. 将分类结果和标准云一同进行可视化展示。
%
% --- 使用方法 ---
% 1. 在 "1. 定义标准云" 部分，根据您的需求修改或定义每个等级的云参数(Ex, En, He)。
%    Ex: 期望，代表了该等级的中心值。
%    En: 熵，代表了该等级范围的模糊度或可接受范围。
%    He: 超熵，代表了熵的不确定性。
% 2. 在 "2. 输入待分类的样本" 部分，输入您需要分类的实际数据。
% 3. 直接运行脚本，即可在命令行窗口看到分类结果，并生成可视化图表。

clc;
clear all;
close all;

%% 1. 定义标准云 (Define Standard Clouds)
% 假设我们有两个评价指标 (例如：指标1-技术性能, 指标2-经济效益)
% 假设有四个评价等级: 优秀, 良好, 中等, 较差
% 每个等级云由两个指标的 (Ex, En, He) 共同定义

% --- 等级定义 ---
% 格式为 [指标1的参数; 指标2的参数]
% 等级1: 优秀 (Excellent)
Ex1 = [95; 90]; En1 = [5; 5]; He1 = [0.5; 0.5];
% 等级2: 良好 (Good)
Ex2 = [80; 75]; En2 = [5; 8]; He2 = [0.5; 0.8];
% 等级3: 中等 (Medium)
Ex3 = [65; 60]; En3 = [8; 10]; He3 = [0.8; 1];
% 等级4: 较差 (Poor)
Ex4 = [40; 45]; En4 = [10; 10]; He4 = [1; 1];

% 将标准云参数存入结构体数组，方便调用
standard_clouds(1).Ex = Ex1; standard_clouds(1).En = En1; standard_clouds(1).He = He1; standard_clouds(1).name = '优秀';
standard_clouds(2).Ex = Ex2; standard_clouds(2).En = En2; standard_clouds(2).He = He2; standard_clouds(2).name = '良好';
standard_clouds(3).Ex = Ex3; standard_clouds(3).En = En3; standard_clouds(3).He = He3; standard_clouds(3).name = '中等';
standard_clouds(4).Ex = Ex4; standard_clouds(4).En = En4; standard_clouds(4).He = He4; standard_clouds(4).name = '较差';

num_classes = length(standard_clouds); % 等级数量

%% 2. 输入待分类的样本 (Input samples to be classified)
% 每个样本是一个行向量 [指标1_值, 指标2_值]
samples = [92, 88;  % 样本1
    78, 80;  % 样本2
    60, 70;  % 样本3
    50, 40]; % 样本4

num_samples = size(samples, 1);
results = cell(num_samples, 1);

%% 3. 计算隶属度并进行分类 (Calculate membership and classify)
fprintf('--- 云模型分类结果 ---\n');
for i = 1:num_samples
    sample = samples(i, :);
    membership_degrees = zeros(1, num_classes);
    
    for j = 1:num_classes
        % 获取当前等级云的参数
        Ex = standard_clouds(j).Ex;
        En = standard_clouds(j).En;
        
        % 计算N维正态云的隶属度
        % 公式: exp(-sum( (x_i - Ex_i)^2 / (2 * En_i^2) ))
        % 注意：这里为了简化分类问题，直接使用了(Ex, En)定义的期望曲线来计算隶属度。
        % 在严格的云发生器中，会先根据(En, He)生成一个随机的En'，再进行计算。
        % 但对于分类问题，使用期望曲线进行匹配是标准做法。
        
        exponent_sum = sum(((sample' - Ex).^2) ./ (2 * En.^2));
        membership_degrees(j) = exp(-exponent_sum);
    end
    
    % 寻找最大隶属度及其对应的等级索引
    [max_degree, class_index] = max(membership_degrees);
    
    % 记录分类结果
    results{i} = standard_clouds(class_index).name;
    
    % 打印结果
    fprintf('样本 %d [', i);
    fprintf('%g, ', sample);
    fprintf('\b\b] 的分类结果是: %s (最大隶属度: %.4f)\n', results{i}, max_degree);
end

%% 4. 可视化展示 (Visualization)
% 绘制二维标准云图和待分类的样本点
figure('Name', '多指标云模型分类可视化');
hold on;
grid on;
box on;

colors = ['r', 'g', 'b', 'm']; % 为不同等级定义颜色
cloud_drop_n = 1000; % 用于可视化的云滴数量

% 绘制每个等级的标准云
for i = 1:num_classes
    % 从(Ex, En, He)生成云滴用于可视化
    Ex = standard_clouds(i).Ex;
    En = standard_clouds(i).En;
    He = standard_clouds(i).He;
    
    % 生成随机的熵 En'
    En_prime_x = normrnd(En(1), He(1), cloud_drop_n, 1);
    En_prime_y = normrnd(En(2), He(2), cloud_drop_n, 1);
    
    % 根据(Ex, En')生成云滴
    x_drops = normrnd(Ex(1), abs(En_prime_x));
    y_drops = normrnd(Ex(2), abs(En_prime_y));
    
    % 绘制云图散点
    scatter(x_drops, y_drops, 15, colors(i), 'filled', 'MarkerFaceAlpha', 0.2);
end

% 绘制待分类的样本点
for i = 1:num_samples
    % 找到该样本分类结果对应的颜色
    class_idx = find(strcmp({standard_clouds.name}, results{i}));
    marker_color = colors(class_idx);
    
    % 用五角星表示样本点
    plot(samples(i,1), samples(i,2), 'p', 'MarkerSize', 15, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', marker_color);
    % 在样本点旁边标注其编号
    text(samples(i,1) + 1, samples(i,2), sprintf('样本 %d', i), 'FontWeight', 'bold');
end

title('多指标云模型分类结果可视化');
xlabel('指标 1');
ylabel('指标 2');

% 创建图例
legend_handles = [];
legend_names = {standard_clouds.name};
for i=1:num_classes
    h = scatter(NaN, NaN, 50, colors(i), 'filled'); % 创建一个不可见的散点用于图例
    legend_handles = [legend_handles, h];
end
legend(legend_handles, legend_names, 'Location', 'northwest', 'FontSize', 12);

hold off;
