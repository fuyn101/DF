%% 高级多维云模型分类器 (K-means自动定级)
% Author: Cline
% Date: 2025/07/19
%
% --- 脚本功能与原理 ---
% 本脚本结合K-means聚类和多维云模型理论，实现一个自适应的多指标分类器。
% 核心原理遵循：
% 1. K-means定级: 首先使用K-means算法对所有样本数据进行聚类，自动发现数据中的簇，并将这些簇作为评价等级。
% 2. 多维云模型参数学习:
%    - 期望向量 (Ex): 从每个聚类（等级）的样本中计算均值。
%    - 熵矩阵 (En): 从每个聚类的样本中计算协方差矩阵，描述其分布形状。
% 3. 实现流程:
%    - (步骤1) 数据聚类: 使用K-means算法对所有样本进行聚类，以自动确定等级划分。
%    - (步骤2) 数据预处理: 对所有数据进行归一化。
%    - (步骤3) 参数计算: 从每个等级的样本数据中计算出其云模型参数(Ex, En)。
%    - (步骤4) 隶属度计算: 使用多维正态概率密度函数计算每个样本对每个标准云的隶属度。
%    - (步骤5) 分类决策: 依据最大隶属度原则进行最终分类。
%    - (步骤6) 可视化分析: 使用等高线图展示标准云的分布，并标出所有样本的分类结果。

clc;
clear all;
close all;

%% 1. 定义原始样本数据并使用 K-means 进行自动分类
% 原始数据，这里合并了原有的标准样本和待测样本
all_samples = [
    95, 90; 92, 93; 98, 88; 94, 91; 96, 89; % 原 "excellent"
    80, 75; 82, 78; 78, 72; 85, 76; 79, 77; % 原 "good"
    65, 60; 68, 65; 62, 58; 70, 63; 64, 61; % 原 "medium"
    40, 45; 45, 42; 38, 48; 42, 40; 35, 46; % 原 "poor"
    92, 88; % 原待测样本 1
    78, 80; % 原待测样本 2
    60, 70; % 原待测样本 3
    50, 40  % 原待测样本 4
    ];

% 使用 K-means 聚类来确定等级
k = 4; % 设定聚类数量为4个等级
fprintf('--- 使用 K-means 对所有样本进行聚类 (k=%d) ---\n', k);
[idx, C] = kmeans(all_samples, k, 'Replicates', 100, 'Start', 'uniform');

% 根据聚类中心的值对等级进行排序 (例如，按中心点坐标和的大小)
% 值越大，等级越高
[~, sorted_centroid_indices] = sort(sum(C, 2), 'descend');

% 创建一个映射，将原始聚类索引映射到排序后的等级 (1=excellent, 2=good, etc.)
rank_map = zeros(k, 1);
rank_map(sorted_centroid_indices) = 1:k;
ranked_idx = rank_map(idx);

% 根据聚类结果重新定义等级数据
% 动态生成等级名称，例如 '等级 1', '等级 2', ...
class_names = cell(1, k);
for i = 1:k
    class_names{i} = sprintf('等级 %d', i);
end

class_data = struct();
for i = 1:k
    class_name = class_names{i};
    % 注意：MATLAB中结构体的字段名不能包含空格，需要转换
    valid_field_name = matlab.lang.makeValidName(class_name);
    class_data.(valid_field_name) = all_samples(ranked_idx == i, :);
end

fprintf('K-means 聚类完成，已自动划分等级。\n\n');

% 待分类的样本现在是所有样本
samples_to_classify = all_samples;

%% 2. 数据预处理 (Data Preprocessing)
% 将所有数据（已在 all_samples 中）进行归一化
all_data = all_samples;

% 最小-最大归一化
min_vals = min(all_data, [], 1);
max_vals = max(all_data, [], 1);
range_vals = max_vals - min_vals;

% 防止除以零
range_vals(range_vals == 0) = 1;

% 应用归一化
normalized_data = (all_data - min_vals) ./ range_vals;

% 分离归一化后的数据到各个等级
norm_class_data = struct();
for i = 1:k
    class_name = class_names{i};
    valid_field_name = matlab.lang.makeValidName(class_name);
    % 从聚类后的 ranked_idx 找到对应等级的归一化数据
    norm_class_data.(valid_field_name) = normalized_data(ranked_idx == i, :);
end
norm_samples_to_classify  = normalized_data; % 所有样本都需要被分类

%% 3. 计算各等级的标准云参数 (Calculate Standard Cloud Parameters)
% Ex: 期望向量 (mean)
% En: 熵矩阵 (covariance matrix)
fprintf('--- 计算得到的标准云参数 (归一化后) ---\n');
standard_clouds = struct('Ex', {}, 'En', {}, 'name', {});
for i = 1:length(class_names)
    name = class_names{i};
    valid_field_name = matlab.lang.makeValidName(name);
    data = norm_class_data.(valid_field_name);
    
    % 检查类中是否有足够的数据点来计算协方差
    if size(data, 1) < 2
        fprintf('警告: 等级 "%s" 的样本不足 (<2)，无法计算协方差。跳过此等级。\n', name);
        continue;
    end
    
    % 计算期望 (Ex) 和 熵 (En)
    standard_clouds(end+1).Ex = mean(data, 1);
    standard_clouds(end).En = cov(data); % 使用协方差矩阵作为熵
    standard_clouds(end).name = name;
    
    fprintf('等级: %s\n', name);
    disp('  期望 Ex:');
    disp(standard_clouds(end).Ex);
    disp('  熵 En (协方差矩阵):');
    disp(standard_clouds(end).En);
end

%% 4. 计算隶属度并进行分类 (Calculate Membership and Classify)
num_classes = length(standard_clouds);
num_samples = size(norm_samples_to_classify, 1);
results = cell(num_samples, 1);

fprintf('\n--- 云模型分类结果 ---\n');
for i = 1:num_samples
    sample = norm_samples_to_classify(i, :);
    membership_degrees = zeros(1, num_classes);
    
    for j = 1:num_classes
        Ex = standard_clouds(j).Ex;
        En = standard_clouds(j).En;
        
        % 检查协方差矩阵是否正定
        [~, p] = chol(En);
        if p ~= 0
            % 如果矩阵不是正定的，添加一个小的扰动使其可逆
            En = En + eye(size(En)) * 1e-6;
        end
        
        % 计算多维隶属度 (基于多维高斯分布的指数部分)
        % 公式: μ = exp(-0.5 * (x - Ex) * inv(En) * (x - Ex)')
        diff = sample - Ex;
        membership_degrees(j) = exp(-0.5 * diff * inv(En) * diff');
    end
    
    % 寻找最大隶属度及其对应的等级索引
    [max_degree, class_index] = max(membership_degrees);
    
    % 记录分类结果
    results{i} = standard_clouds(class_index).name;
    
    % 打印原始样本的分类结果
    original_sample = samples_to_classify(i, :);
    fprintf('原始样本 %d [%g, %g] 的分类结果是: %s (最大隶属度: %.4f)\n', ...
        i, original_sample(1), original_sample(2), results{i}, max_degree);
end

%% 5. 可视化分析 (Visualization)
figure('Name', '高级多维云模型分类可视化 (K-means定级)');
hold on;
grid on;
box on;

% 动态生成颜色和标记以匹配k值
colors = lines(k); % 使用MATLAB内置的颜色图
class_markers = {'o', 's', 'd', '^', 'v', '>', '<', 'p', 'h', '*'}; % 提供更多标记
if k > length(class_markers)
    % 如果k值过大，循环使用标记
    class_markers = repmat(class_markers, 1, ceil(k/length(class_markers)));
end

% 使用等高线图绘制标准云的概率密度
[X, Y] = meshgrid(linspace(0, 1, 100), linspace(0, 1, 100));
for i = 1:num_classes
    Ex = standard_clouds(i).Ex;
    En = standard_clouds(i).En;
    
    % 再次检查En是否正定以用于绘图
    [~, p] = chol(En);
    if p ~= 0
        En = En + eye(size(En)) * 1e-6;
    end
    
    % 计算网格上每个点的概率密度
    Z = mvnpdf([X(:) Y(:)], Ex, En);
    Z = reshape(Z, size(X));
    
    % 绘制等高线
    contour(X, Y, Z, 3, 'Color', colors(i,:), 'LineWidth', 1.5);
end

% 绘制所有样本点 (归一化后)
for i = 1:num_samples
    class_idx_str = results{i};
    class_idx = find(strcmp({standard_clouds.name}, class_idx_str));
    if isempty(class_idx)
        continue; % 如果找不到对应的类
    end
    plot(norm_samples_to_classify(i,1), norm_samples_to_classify(i,2), 'p', ...
        'MarkerSize', 12, 'MarkerEdgeColor', 'k', 'MarkerFaceColor', colors(class_idx,:));
    text(norm_samples_to_classify(i,1) + 0.01, norm_samples_to_classify(i,2), ...
        sprintf('样本 %d', i), 'FontWeight', 'bold');
end

title('多维云模型分类结果 (K-means定级, 归一化空间)');
xlabel('指标 1 (归一化)');
ylabel('指标 2 (归一化)');

% 创建图例
legend_handles = [];
legend_names = {standard_clouds.name};
for i=1:num_classes
    h = plot(NaN, NaN, '-', 'Color', colors(i,:), 'LineWidth', 2);
    legend_handles = [legend_handles, h];
end
legend(legend_handles, legend_names, 'Location', 'northwest', 'FontSize', 12);

hold off;
