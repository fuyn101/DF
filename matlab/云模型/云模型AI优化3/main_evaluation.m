% =========================================================================
%         覆岩阻隔水性能【宏观-微观】双尺度云模型评价主程序
%
% 功能:
%   1. 宏观分析：通过聚合所有样本，生成一个代表整个研究区的
%      “综合评价云”，用于判断区域总体性能。
%   2. 微观分析：通过计算每个钻孔的综合得分，并使用云相似度
%      算法，为每个钻孔进行精准评级。
%   3. 输出所有计算结果，并可视化宏观评价云。
%
% 作者: [您的姓名]
% 日期: [当前日期]
% =========================================================================

%% 1. 初始化设置
clear; 
clc; 
close all;

%% 2. 用户输入数据 (所有配置在此完成)
% =======================================================================
% >>>>>>>>>>>>>>>>>>    请在此区域填入您的数据    <<<<<<<<<<<<<<<<<<<<<<
% =======================================================================

% --- 2.1 输入您的所有钻孔的原始数据 ---
% 格式: N行 x M列的矩阵 (N个钻孔, M个指标)
% 注意：您的两个原始脚本中指标数量不一致（8 vs 6），这里以8个指标为例。
% 请确保这里的原始数据、指标名称、类型和权重在数量上完全匹配。
original_data = [
  1.479832578	47.73	0.9410 	4.87 	1.4158 	0.7840 
1.658069295	54.39	0.9685 	5.38 	1.0978 	0.8795 
1.684438334	60.16	0.9251 	5.24 	1.1437 	0.7255 
1.367515564	61.49	0.9196 	5.52 	0.9832 	0.7500 
1.336315979	82.06	0.8285 	6.75 	0.4547 	0.7626 
1.421103381	68.03	0.9492 	5.74 	0.8891 	0.6579 
1.197381555	51.77	0.9528 	5.14 	1.2344 	0.6879 
1.252493636	59.51	0.9143 	5.54 	0.9676 	0.8300 
1.294879693	62.23	0.9310 	5.51 	0.9948 	0.8100 
1.280575857	50.35	0.9042 	5.70 	0.8373 	0.7243 
1.195524035	55.18	0.8816 	5.03 	1.2413 	0.5881 
1.303212285	56.52	0.8659 	5.52 	0.9411 	0.5223 
1.264548001	72.24	0.8913 	5.74 	0.8551 	0.7988 
1.29675506	66.02	0.8490 	6.13 	0.6670 	0.7131 
1.364149411	54.06	0.8629 	5.99 	0.7282 	0.7300 
1.185901357	55.42	0.8533 	5.73 	0.7286 	0.6500 
1.225749366	80.13	0.9018 	5.66 	0.8972 	0.5178 
1.265013015	87.61	0.8354 	6.81 	0.4423 	0.5650 
1.280717424	81.05	0.8818 	5.69 	0.8691 	0.5500 
1.221096479	69.32	0.9053 	6.05 	0.7293 	0.6975 
1.228003041	89.77	0.8659 	5.53 	0.9372 	0.4363 
1.052937308	76.09	0.9776 	4.49 	1.7408 	0.6554 
1.28144786	59.65	0.8750 	6.18 	0.6608 	0.7508 
1.348400008	74	0.8342 	5.93 	0.7382 	0.5876 
1.249598455	65.17	0.8847 	6.14 	0.6804 	0.9000 
1.322786194	66.95	0.8705 	6.06 	0.7033 	0.8996 
];

% --- 2.2 定义指标的名称和类型 ---
indicator_names = {'断层分维值', '隔水层有效厚度', '质量比值系数', '复合抗压强度', '塑脆性岩厚比', '岩芯采取率'};
indicator_types = {'negative', 'positive', 'positive', 'positive', 'positive', 'positive'};

% --- 2.3 输入指标的组合权重 ---
indicator_weights = [0.210800305	0.218112123	0.137081682	0.167657053	0.137187901	0.129160934];

% --- 2.4 定义【混合归一化】的阈值 ---
% 为每个指标设置阈值。用一个空的[]表示该指标使用“相对归一化”。
hybrid_thresholds = {
    [],...          % 指标1: 断层分维值
    [5,50], ...    % 指标2: 隔水层有效厚度 (绝对阈值：5米=0分, 50米=100分)
    [],  ...        % 指标3: 质量比值系数
    [], ...         % 指标4: 复合抗压强度
    [],  ...        % 指标5: 塑脆性岩厚比
    [],  ...        % 指标6: 岩芯采取率
    [],   ...       % 指标7: 面积缝隙率
    []           % 指标8: 缝隙体积
};

% =======================================================================
% >>>>>>>>>>>>>>>>>>>>>      数据填充结束      <<<<<<<<<<<<<<<<<<<<<<<<<
% =======================================================================

%% 3. 数据预处理 (调用混合归一化)
fprintf('--> 步骤 1: 正在使用【混合模式】对原始数据进行归一化...\n');
normalized_data = normalize_data_hybrid(original_data, indicator_types, hybrid_thresholds);
fprintf('归一化完成。\n\n');

%% 4. 宏观尺度分析：生成研究区综合评价云
fprintf('========== 宏观尺度分析 ========== \n');

% 步骤 1: 计算8个指标的“指标云”
fprintf('--> 步骤 2: 正在计算各评价指标的指标云 (Ex, En, He)...\n');
indicator_clouds = calculate_indicator_clouds_from_samples(normalized_data);

% 步骤 2: 将指标云加权聚合成综合评价云
fprintf('--> 步骤 3: 正在根据权重将指标云聚合成【研究区综合评价云】...\n');
% 采用与参考文献一致的线性加权聚合方法
comprehensive_cloud = aggregate_clouds_weighted_linear(indicator_clouds, indicator_weights);
fprintf('宏观分析完成。\n');

% 打印宏观分析结果
fprintf('\n------------------ 各指标云的数字特征 --------------------\n');
fprintf('%-12s |   %-8s |   %-8s |   %-8s\n', '指标名称', 'Ex', 'En', 'He');
fprintf('------------------------------------------------------------\n');
for i = 1:length(indicator_names)
    fprintf('%-14s |  %-8.4f |  %-8.4f |  %-8.4f\n', ...
            indicator_names{i}, ...
            indicator_clouds(i).Ex, ...
            indicator_clouds(i).En, ...
            indicator_clouds(i).He);
end
fprintf('------------------------------------------------------------\n');
fprintf('\n=========== 研究区覆岩阻隔水性能【综合评价云】结果 ===========\n');
fprintf('综合期望 (Ex_综): %.4f\n', comprehensive_cloud.Ex);
fprintf('综合熵 (En_综):   %.4f\n', comprehensive_cloud.En);
fprintf('综合超熵 (He_综): %.4f\n', comprehensive_cloud.He);
fprintf('================================================================\n\n');

%% 5. 微观尺度分析：对每个钻孔进行评级
fprintf('========== 微观尺度分析 ========== \n');

% 步骤 1: 建立五级评价等级标准云
fprintf('--> 步骤 4: 正在建立五级评价标准云...\n');
labels_5 = {'I级 (优)', 'II级 (良)', 'III级 (中)', 'IV级 (差)', 'V级 (劣)'};
intervals_5 = {[85, 100], [65, 85], [45, 65], [25, 45], [0, 25]};
standard_clouds_5 = build_standard_clouds(labels_5, intervals_5);
fprintf('标准云建立完成。\n');

% 步骤 2: 计算每个钻孔的综合得分
fprintf('--> 步骤 5: 正在计算各钻孔的综合得分...\n');
comprehensive_scores = calculate_scores(normalized_data, indicator_weights);
fprintf('综合得分计算完成。\n');

% 步骤 3: 基于云相似度确定每个钻孔的等级
fprintf('--> 步骤 6: 正在基于云相似度确定各钻孔最终等级...\n');
[determined_levels, similarity_matrix] = determine_levels_by_similarity(comprehensive_scores, standard_clouds_5);
fprintf('等级评定完成。\n');

% 打印微观分析结果
fprintf('\n======================= 各钻孔最终评价结果汇总 =======================\n');
fprintf('%-10s | %-12s | %-15s | %-10s\n', '钻孔ID', '综合得分', '最大相似度', '最终等级');
fprintf('------------------------------------------------------------------------\n');
for i = 1:size(original_data, 1)
    level_index = determined_levels(i);
    level_label = standard_clouds_5(level_index).Label;
    max_similarity = similarity_matrix(i, level_index);
    fprintf(' ZK%-7d |   %-10.4f |     %-12.4f | %s\n', i, comprehensive_scores(i), max_similarity, level_label);
end
fprintf('========================================================================\n\n');

%% 6. 可视化：绘制宏观综合评价云图
fprintf('--> 步骤 7: 正在生成可视化图表...\n');

% 准备绘图所需的数据

vis_clouds = {standard_clouds_5(1), standard_clouds_5(2), standard_clouds_5(3), standard_clouds_5(4), standard_clouds_5(5), comprehensive_cloud};
vis_legends = {standard_clouds_5.Label, '研究区综合评价云'};
vis_colors = {'#0072BD', '#77AC30', '#EDB120', '#D95319', '#A2142F', '#7E2F8E'};
vis_sizes = [15, 15, 15, 15, 15, 30];

% 开始绘图
figure('Name', '研究区综合评价云与标准云对比图', 'Position', [100, 100, 1000, 600]);
hold on; 
scatter_handles = gobjects(1, length(vis_clouds)); 

for i = 1:length(vis_clouds)
    current_cloud = vis_clouds{i};
    num_drops = 2000;
    En_prime = normrnd(current_cloud.En, current_cloud.He, [1, num_drops]);
    % 确保 En_prime 不为负
    En_prime(En_prime<0) = 0;
    x = normrnd(current_cloud.Ex, En_prime, [1, num_drops]);
    % 避免除以零
    mu_denom = 2 * En_prime.^2;
    mu_denom(mu_denom == 0) = 1e-6;
    mu = exp(-(x - current_cloud.Ex).^2 ./ mu_denom);
    scatter_handles(i) = scatter(x, mu, vis_sizes(i), 'filled', 'MarkerFaceColor', vis_colors{i}, 'MarkerFaceAlpha', 0.5);
end

hold off;

% 美化图形
xlim([0, 100]);
ylim([0, 1.1]);
title('研究区覆岩阻隔水性能综合评价云图', 'FontSize', 16, 'FontWeight', 'bold');
xlabel('评价分数 / Score', 'FontSize', 12, 'FontWeight', 'bold');
ylabel('隶属度 / Membership Degree', 'FontSize', 12, 'FontWeight', 'bold');
grid on;
ax = gca;
ax.FontSize = 12;
ax.FontWeight = 'bold';
xline(85, '--k', 'LineWidth', 1.5);
xline(65, '--k', 'LineWidth', 1.5);
xline(45, '--k', 'LineWidth', 1.5);
xline(25, '--k', 'LineWidth', 1.5);

legend(scatter_handles, vis_legends, 'Location', 'northeast', 'FontSize', 10);
fprintf('可视化图表生成完毕。\n');

%% 7. 辅助函数库 (所有函数都放在主脚本末尾)

% =================== 归一化函数 ===================
function normalized_data = normalize_data_hybrid(data_matrix, types, thresholds)
    [n_samples, n_indicators] = size(data_matrix);
    normalized_data = zeros(n_samples, n_indicators);

    for j = 1:n_indicators
        col_data = data_matrix(:, j);
        threshold = thresholds{j};
        type = types{j};

        if isempty(threshold)
            % 使用相对归一化 (Min-Max)
            min_val = min(col_data);
            max_val = max(col_data);
            range = max_val - min_val;
            if range == 0; range = 1; end % 避免除以零

            if strcmp(type, 'positive')
                normalized_data(:, j) = (col_data - min_val) / range * 100;
            else % 'negative'
                normalized_data(:, j) = (max_val - col_data) / range * 100;
            end
        else
            % 使用绝对阈值归一化
            C_min = threshold(1);
            C_max = threshold(2);
            range = C_max - C_min;
            if range == 0; range = 1; end % 避免除以零
            
            if strcmp(type, 'positive')
                temp_data = (col_data - C_min) / range * 100;
            else % 'negative'
                temp_data = (C_max - col_data) / range * 100;
            end
            % 确保结果在 [0, 100] 区间内
            normalized_data(:, j) = max(0, min(100, temp_data));
        end
    end
end

% =================== 宏观分析函数 ===================
function indicator_clouds = calculate_indicator_clouds_from_samples(data_matrix)
    [~, n_indicators] = size(data_matrix);
    indicator_clouds = struct('Ex', cell(1, n_indicators), 'En', cell(1, n_indicators), 'He', cell(1, n_indicators));
    for j = 1:n_indicators
        A = data_matrix(:, j);
        Ex = mean(A);
        En = mean(abs(A - Ex)) * sqrt(pi/2);
        S2 = var(A, 1);
        He = sqrt(max(0, S2 - En^2));
        indicator_clouds(j).Ex = Ex;
        indicator_clouds(j).En = En;
        indicator_clouds(j).He = He;
    end
end

function comp_cloud = aggregate_clouds_weighted_linear(indicator_clouds, weights)
    % 采用与参考文献一致的线性加权平均方法
    Ex_values = [indicator_clouds.Ex];
    En_values = [indicator_clouds.En];
    He_values = [indicator_clouds.He];
%%%%%%%%%这里！！！！！！更改优化了一下与公式不一致%%%%%%%%%%%%%
    Ex_comp = sum(Ex_values .* weights);
    En_comp = sqrt(sum(En_values.* weights));
    He_comp = sqrt(sum(He_values.* weights));
    
    comp_cloud = struct('Ex', Ex_comp, 'En', En_comp, 'He', He_comp);
end

% =================== 微观分析函数 ===================
function standard_clouds = build_standard_clouds(labels, intervals)
    num_levels = length(labels);
    standard_clouds = struct('Ex', cell(1,num_levels), 'En', cell(1,num_levels), 'He', cell(1,num_levels), 'Label', cell(1,num_levels));
    for i = 1:num_levels
        C_min = intervals{i}(1);
        C_max = intervals{i}(2);
        standard_clouds(i).Ex = (C_min + C_max) / 2;
        standard_clouds(i).En = (C_max - C_min) / 6;
        standard_clouds(i).He = standard_clouds(i).En / 10; % 按照论文公式，He = En/10
        standard_clouds(i).Label = labels{i};
    end
end

function scores = calculate_scores(normalized_data, weights)
    scores = normalized_data * weights';
end

function [levels, sim_matrix] = determine_levels_by_similarity(scores, standard_clouds)
    num_scores = length(scores);
    num_levels = length(standard_clouds);
    sim_matrix = zeros(num_scores, num_levels);

    for i = 1:num_scores
        for k = 1:num_levels
            sim_matrix(i, k) = calculate_similarity(scores(i), standard_clouds(k));
        end
    end
    [~, levels] = max(sim_matrix, [], 2);
end

function sim = calculate_similarity(score, standard_cloud)
    % 生成大量符合标准云分布的云滴，来计算score的隶属度期望
    num_drops = 2000;
    En_prime = normrnd(standard_cloud.En, standard_cloud.He, [1, num_drops]);
    En_prime(En_prime<0) = 0; % 熵不能为负
    
    % 使用目标分数(score)作为输入，计算其对这些随机云滴的隶属度
    mu_denom = 2 * En_prime.^2;
    mu_denom(mu_denom==0) = 1e-6; % 避免除以零
    mu_values = exp(-(score - standard_cloud.Ex).^2 ./ mu_denom);
    
    sim = mean(mu_values);
end
