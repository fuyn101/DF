% =========================================================================
%         覆岩阻隔水性能【宏观-微观】双尺度云模型评价主程序
%
% 版本: 2.0 (增强版)
%
% 新增功能:
%   1. 演示计算：以ZK1钻孔为例，详细展示单一样本的评价过程。
%   2. 对比分析：分别对“6个宏观指标”和“8个宏/微观指标”两种情景进行
%      独立评价，以分析微观指标引入后的影响。
%   3. 结果汇总：生成一个清晰的对比表，直观展示两种情景下各钻孔的
%      评价结果差异。
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

% --- 2.1 输入您的所有钻孔的【完整8指标】原始数据 ---
% 格式: N行 x 8列的矩阵 (N个钻孔, 8个指标)
original_data_8_indicators = [
    1.479832578	47.73	0.9410 	4.87 	1.4158 	0.7840 	2.225271024	0.092939881
1.658069295	54.39	0.9685 	5.38 	1.0978 	0.8795 	2.21291999	0.091608121
1.684438334	60.16	0.9251 	5.24 	1.1437 	0.7255 	2.206944147	0.091027262
1.367515564	61.49	0.9196 	5.52 	0.9832 	0.7500 	2.231105299	0.093624478
1.336315979	82.06	0.8285 	6.75 	0.4547 	0.7626 	2.225745203	0.093015451
1.421103381	68.03	0.9492 	5.74 	0.8891 	0.6579 	2.215318299	0.091909717
1.197381555	51.77	0.9528 	5.14 	1.2344 	0.6879 	2.247140955	0.095758953
1.252493636	59.51	0.9143 	5.54 	0.9676 	0.8300 	2.251040437	0.096392692
1.294879693	62.23	0.9310 	5.51 	0.9948 	0.8100 	2.254724301	0.097027582
1.280575857	50.35	0.9042 	5.70 	0.8373 	0.7243 	2.270720036	0.100455605
1.195524035	55.18	0.8816 	5.03 	1.2413 	0.5881 	2.276629973	0.101384896
1.303212285	56.52	0.8659 	5.52 	0.9411 	0.5223 	2.257264842	0.097771703
1.264548001	72.24	0.8913 	5.74 	0.8551 	0.7988 	2.272336383	0.101068803
1.29675506	66.02	0.8490 	6.13 	0.6670 	0.7131 	2.26451949	0.100002759
1.364149411	54.06	0.8629 	5.99 	0.7282 	0.7300 	2.265098703	0.099871232
1.185901357	55.42	0.8533 	5.73 	0.7286 	0.6500 	2.272221607	0.102817188
1.225749366	80.13	0.9018 	5.66 	0.8972 	0.5178 	2.27438736	0.105372195
1.265013015	87.61	0.8354 	6.81 	0.4423 	0.5650 	2.273765003	0.107087228
1.280717424	81.05	0.8818 	5.69 	0.8691 	0.5500 	2.276560491	0.107297032
1.221096479	69.32	0.9053 	6.05 	0.7293 	0.6975 	2.264263736	0.106503137
1.228003041	89.77	0.8659 	5.53 	0.9372 	0.4363 	2.271177669	0.106024726
1.052937308	76.09	0.9776 	4.49 	1.7408 	0.6554 	2.246003813	0.103936164
1.28144786	59.65	0.8750 	6.18 	0.6608 	0.7508 	2.2656773	0.108579173
1.348400008	74	0.8342 	5.93 	0.7382 	0.5876 	2.280006545	0.109209166
1.249598455	65.17	0.8847 	6.14 	0.6804 	0.9000 	2.260318356	0.107214087
1.322786194	66.95	0.8705 	6.06 	0.7033 	0.8996 	2.255396819	0.109123015
1.329552878	60.5	0.9127 	4.93 	0.7263 	0.5200 	1.989317156	0.082048767
1.257258643	62.05	0.9254 	4.84 	0.7941 	0.5000 	1.963740196	0.077615448
1.171358739	65.02	0.9234 	4.85 	0.7869 	0.4150 	1.963983291	0.075282358
1.264433794	60.19	0.9131 	4.93 	0.7259 	0.5320 	1.98483736	0.074685606
1.348561354	66.4	0.9130 	4.84 	0.7676 	0.5950 	1.981759925	0.071898765
1.549531836	63.87	0.9080 	4.91 	0.7245 	0.5250 	2.000577417	0.069883498
1.233144913	73.83	0.9018 	4.00 	1.2733 	0.8640 	1.974938167	0.103144066
1.387530346	75.05	0.9113 	4.15 	1.1905 	0.8430 	2.33758	0.08158
1.35366293	70.54	0.9033 	4.30 	1.0572 	0.8430 	2.102407769	0.097275085
1.360536786	67.69	0.9028 	4.48 	0.9407 	0.8100 	2.04748175	0.101469469
1.455776283	56.29	0.8926 	5.78 	0.3707 	0.7510 	2.294076539	0.095425369
1.341115207	65.9	0.9100 	4.66 	0.8549 	0.6570 	1.970445119	0.104984021
1.588533481	58.73	0.8945 	5.13 	0.6035 	0.9750 	2.086402033	0.104575886
1.569393841	54.56	0.8799 	5.37 	0.4865 	0.7960 	2.162419976	0.106938687
1.487526308	50.5	0.8522 	5.22 	0.4977 	0.8057 	2.27606	0.11564
1.155980276	66.8	0.9168 	4.82 	0.7866 	0.5710 	1.966964543	0.073909151
1.258861153	59.2	0.9224 	4.79 	0.8177 	0.5154 	1.976175504	0.076550421
1.240689299	60.4	0.9252 	4.82 	0.8075 	0.5100 	1.979085562	0.075074178
1.275965151	61.7	0.9195 	4.90 	0.7556 	0.5300 	1.982809126	0.076347903
1.397573659	63.9	0.9185 	4.88 	0.7626 	0.5170 	1.94219604	0.084783739
1.376119522	49.6	0.8917 	5.20 	0.5690 	0.7000 	1.953338853	0.105710227
1.207807031	65.9	0.9120 	4.79 	0.7928 	0.6650 	1.918274592	0.104430877
1.174295957	81.1	0.9158 	4.83 	0.7802 	0.6500 	1.900516116	0.10244685
1.257649981	72.9	0.8997 	4.02 	1.2500 	0.8470 	1.95846	0.10494
1.620603688	73.7	0.8048 	5.67 	0.2451 	0.8510 	2.0216	0.0674
1.580458559	68.01	0.8579 	5.35 	0.4520 	0.7520 	1.9975	0.11322
1.18462431	61.15	0.9137 	5.36 	0.8139 	0.9060 	2.204810055	0.118029708
1.203654273	74.35	0.8677 	5.78 	0.7064 	0.8471 	2.174800522	0.109586897
1.32995396	58.9	0.8736 	6.93 	0.3347 	0.7330 	2.14433399	0.100898422
1.323965986	54.25	0.8872 	5.63 	0.7952 	0.7953 	2.152123235	0.104123647
1.091156709	60.65	0.8500 	7.06 	0.2857 	0.8829 	2.20380712	0.113529148
1.097045477	62.9	0.9001 	5.96 	0.6667 	0.9149 	2.171501585	0.106149676
1.160428426	56.93	0.9179 	6.26 	0.5720 	0.9098 	2.152247271	0.101045745
1.117921733	60.37	0.8885 	6.37 	0.4793 	0.8400 	2.219565785	0.115283146
1.080011235	68.65	0.9527 	5.78 	0.8096 	0.8694 	2.172569445	0.103161879
1.359864582	55.81	0.8629 	6.46 	0.4583 	0.8462 	2.22503771	0.107450193
1.238776362	55.18	0.8500 	6.22 	0.5239 	0.8464 	2.211244168	0.106032968
1.158937167	55.25	0.9226 	4.77 	1.3847 	0.8479 	2.197410888	0.104165075
1.203873506	77.83	0.8673 	5.84 	0.6517 	0.8700 	2.181347232	0.101621184
1.299553906	79.58	0.7724 	7.43 	0.1599 	0.7889 	2.161841755	0.0980217
1.302589672	75.73	0.7943 	6.84 	0.2780 	0.6980 	2.14729829	0.09517037
1.331159036	78	0.8772 	6.28 	0.5179 	0.8500 	2.229179387	0.104484462
1.347666518	77.8	0.8444 	5.61 	0.6748 	0.8540 	2.175935005	0.097543455
1.389935528	81.41	0.8844 	6.71 	0.4013 	0.9300 	2.120660622	0.093474157
1.143320929	86.9	0.9075 	5.80 	0.7415 	0.9150 	2.186361564	0.11174424
1.231442451	77.09	0.8845 	6.46 	0.4563 	0.8520 	2.131097935	0.094527461
1.088518143	79.8	0.9158 	6.02 	0.6197 	0.9490 	2.158121045	0.101284871
1.115290839	80.72	0.9040 	5.70 	0.7681 	0.8090 	2.186954251	0.104246986
];

% --- 2.2 定义【情景一：6个宏观指标】的配置 ---
indicator_names_6 = {'断层分维值', '隔水层有效厚度', '质量比值系数', '复合抗压强度', '塑脆性岩厚比', '岩芯采取率'};
indicator_types_6 = {'negative', 'positive', 'positive', 'positive', 'positive', 'positive'};
indicator_weights_6 = [0.2108, 0.2181, 0.1371, 0.1677, 0.1372, 0.1292]; % 请确保权重和为1

% --- 2.3 定义【情景二：8个宏观+微观指标】的配置 ---
indicator_names_8 = {'断层分维值', '隔水层有效厚度', '质量比值系数', '复合抗压强度', '塑脆性岩厚比', '岩芯采取率', '面积缝隙率', '缝隙体积'};
indicator_types_8 = {'negative', 'positive', 'positive', 'positive', 'positive', 'positive', 'negative', 'negative'};
indicator_weights_8 = [0.1800, 0.1836, 0.0732, 0.0935, 0.1327, 0.1083, 0.1241, 0.1047]; % 请确保权重和为1

% --- 2.4 定义【混合归一化】的阈值 (8个指标) ---
% 6指标情景会自动截取前6个阈值
hybrid_thresholds_8 = {
    [],...          % 指标1: 断层分维值
    [5, 50], ...    % 指标2: 隔水层有效厚度 (绝对阈值：5米=0分, 50米=100分)
    [], ...         % 指标3: 质量比值系数
    [], ...         % 指标4: 复合抗压强度
    [], ...         % 指标5: 塑脆性岩厚比
    [], ...         % 指标6: 岩芯采取率
    [], ...        % 指标7: 面积缝隙率
    []           % 指标8: 缝隙体积
};

% =======================================================================
% >>>>>>>>>>>>>>>>>>>>>      数据填充结束      <<<<<<<<<<<<<<<<<<<<<<<<<
% =======================================================================

%% 3. 演示范例计算过程 (以 ZK1 钻孔为例,采用8指标情景)
fprintf('==================== ZK1 钻孔评价过程演示 (8指标情景) ====================\n\n');
% 步骤 1: 提取ZK1的原始数据
zk1_original_data = original_data_8_indicators(1, :);
fprintf('1. 提取 ZK1 原始数据:\n   ');
fprintf('%.4f  ', zk1_original_data);
fprintf('\n\n');

% 步骤 2: 对ZK1数据进行归一化
zk1_normalized_data = normalize_data_hybrid(zk1_original_data, indicator_types_8, hybrid_thresholds_8);
fprintf('2. 对 ZK1 数据进行归一化 (部分指标用阈值[5,50],其余用min-max):\n   ');
fprintf('%.4f  ', zk1_normalized_data);
fprintf('\n\n');

% 步骤 3: 计算ZK1的加权综合得分
zk1_score = calculate_scores(zk1_normalized_data, indicator_weights_8);
fprintf('3. 计算 ZK1 加权综合得分:\n   Score = (%.2f*%.4f) + (%.2f*%.4f) + ... = %.4f\n\n', ...
        zk1_normalized_data(1), indicator_weights_8(1), zk1_normalized_data(2), indicator_weights_8(2), zk1_score);

% 步骤 4: 建立标准云并计算相似度
labels_5 = {'I级 (优)', 'II级 (良)', 'III级 (中)', 'IV级 (差)', 'V级 (劣)'};
intervals_5 = {[85, 100], [65, 85], [45, 65], [25, 45], [0, 25]};
standard_clouds_5 = build_standard_clouds(labels_5, intervals_5);
fprintf('4. 计算 ZK1 得分 (%.4f) 与各标准云的相似度:\n', zk1_score);
zk1_similarities = zeros(1, 5);
for k = 1:5
    zk1_similarities(k) = calculate_similarity(zk1_score, standard_clouds_5(k));
    fprintf('   与 %-8s 的相似度: %.4f\n', standard_clouds_5(k).Label, zk1_similarities(k));
end
fprintf('\n');

% 步骤 5: 确定最终等级
[max_sim, best_level_idx] = max(zk1_similarities);
final_level_label = standard_clouds_5(best_level_idx).Label;
fprintf('5. 确定最终等级:\n   最大相似度为 %.4f，对应等级为: %s\n', max_sim, final_level_label);
fprintf('============================================================================\n\n');
pause(2); % 暂停2秒，方便阅读

%% 4. 主循环：进行双情景对比分析

% 初始化存储结果的变量
num_samples = size(original_data_8_indicators, 1);
results_storage = struct(); 

for scenario = 1:2
    
    if scenario == 1
        % ---------- 情景一：6个宏观指标 ----------
        fprintf('########################### 开始分析【情景一：6个宏观指标】 ###########################\n');
        current_data = original_data_8_indicators(:, 1:6);
        current_names = indicator_names_6;
        current_types = indicator_types_6;
        current_weights = indicator_weights_6;
        current_thresholds = hybrid_thresholds_8(1:6);
        num_indicators = 6;
    else
        % ---------- 情景二：8个宏观+微观指标 ----------
        fprintf('\n####################### 开始分析【情景二：全部8个指标】 #######################\n');
        current_data = original_data_8_indicators;
        current_names = indicator_names_8;
        current_types = indicator_types_8;
        current_weights = indicator_weights_8;
        current_thresholds = hybrid_thresholds_8;
        num_indicators = 8;
    end
    
    % --- 4.1 数据预处理 ---
    fprintf('--> 步骤 1: 正在对 %d 个指标的数据进行归一化...\n', num_indicators);
    normalized_data = normalize_data_hybrid(current_data, current_types, current_thresholds);
    
    % --- 4.2 宏观分析 ---
    fprintf('--> 步骤 2: 正在计算各指标云并聚合成【研究区综合评价云】...\n');
    indicator_clouds = calculate_indicator_clouds_from_samples(normalized_data);
    comprehensive_cloud = aggregate_clouds_weighted_sqrt(indicator_clouds, current_weights);
    
    % 打印宏观结果
    fprintf('\n=========== 研究区覆岩阻隔水性能【综合评价云】(%d指标) ===========\n', num_indicators);
    fprintf('综合期望 (Ex_综): %.4f\n', comprehensive_cloud.Ex);
    fprintf('综合熵 (En_综):   %.4f\n', comprehensive_cloud.En);
    fprintf('综合超熵 (He_综): %.4f\n', comprehensive_cloud.He);
    fprintf('================================================================\n');

    % --- 4.3 微观分析 ---
    fprintf('--> 步骤 3: 正在计算各钻孔综合得分并进行评级...\n');
    comprehensive_scores = calculate_scores(normalized_data, current_weights);
    [determined_levels, similarity_matrix] = determine_levels_by_similarity(comprehensive_scores, standard_clouds_5);
    
    % --- 4.4 存储结果 ---
    level_labels = cell(num_samples, 1);
    for i = 1:num_samples
        level_labels{i} = standard_clouds_5(determined_levels(i)).Label;
    end
    
    if scenario == 1
        results_storage.scores_6 = comprehensive_scores;
        results_storage.levels_6 = level_labels;
    else
        results_storage.scores_8 = comprehensive_scores;
        results_storage.levels_8 = level_labels;
    end
    
    % --- 4.5 可视化 ---
    fprintf('--> 步骤 4: 正在生成可视化图表...\n');
    figure_title = sprintf('研究区综合评价云图 (%d个指标)', num_indicators);
    figure('Name', figure_title, 'Position', [100 + 550*(scenario-1), 100, 1000, 600]);
    hold on;
    vis_clouds = {standard_clouds_5(1), standard_clouds_5(2), standard_clouds_5(3), standard_clouds_5(4), standard_clouds_5(5), comprehensive_cloud};
    vis_legends = {standard_clouds_5.Label, '研究区综合评价云'};
    vis_colors = {'#0072BD', '#77AC30', '#EDB120', '#D95319', '#A2142F', '#7E2F8E'};
    vis_sizes = [15, 15, 15, 15, 15, 30];
    scatter_handles = gobjects(1, length(vis_clouds)); 
    for i = 1:length(vis_clouds)
        cc = vis_clouds{i};
        x_drops = normrnd(cc.Ex, normrnd(cc.En, cc.He, [1, 2000]), [1, 2000]);
        mu_drops = exp(-(x_drops - cc.Ex).^2 ./ (2 * normrnd(cc.En, cc.He, [1, 2000]).^2));
        scatter_handles(i) = scatter(x_drops, mu_drops, vis_sizes(i), 'filled', 'MarkerFaceColor', vis_colors{i}, 'MarkerFaceAlpha', 0.5);
    end
    hold off;
    xlim([0, 100]); ylim([0, 1.1]);
    title(figure_title, 'FontSize', 16, 'FontWeight', 'bold');
    xlabel('评价分数 / Score', 'FontSize', 12); ylabel('隶属度 / Membership Degree', 'FontSize', 12);
    grid on; ax = gca; ax.FontSize = 12;
    xline([85, 65, 45, 25], '--k', 'LineWidth', 1.5);
    legend(scatter_handles, vis_legends, 'Location', 'northeast', 'FontSize', 10);
    
    fprintf('情景 %d 分析完成。\n', scenario);
    if scenario == 1, pause(1); end
end


%% 5. 最终结果对比分析
fprintf('\n\n#####################################################################################');
fprintf('\n######################   最终评价结果对比 (6指标 vs 8指标)   ######################');
fprintf('\n#####################################################################################\n\n');

fprintf('%-8s | %-12s | %-12s | %-12s | %-12s | %-s\n', ...
    '钻孔ID', '得分 (6指标)', '等级 (6指标)', '得分 (8指标)', '等级 (8指标)', '评级是否变化');
fprintf('-------------------------------------------------------------------------------------\n');

for i = 1:num_samples
    score_6 = results_storage.scores_6(i);
    level_6 = results_storage.levels_6{i};
    score_8 = results_storage.scores_8(i);
    level_8 = results_storage.levels_8{i};
    
    if strcmp(level_6, level_8)
        change_flag = '否';
    else
        change_flag = '是 (*)'; % 高亮显示变化
    end
    
    fprintf(' ZK%-5d |    %-10.4f | %-12s |    %-10.4f | %-12s | %s\n', ...
        i, score_6, level_6, score_8, level_8, change_flag);
end
fprintf('-------------------------------------------------------------------------------------\n');
fprintf('\n分析结束。请查看生成的对比表和两张评价云图。\n');


%% 6. 辅助函数库 (所有函数都放在主脚本末尾)

% --- 注意：根据您的注释，对聚合函数进行了修改 ---
function comp_cloud = aggregate_clouds_weighted_sqrt(indicator_clouds, weights)
    % 采用加权平方根聚合方法
    Ex_values = [indicator_clouds.Ex];
    En_values = [indicator_clouds.En];
    He_values = [indicator_clouds.He];
    
    Ex_comp = sum(Ex_values .* weights);  % 期望通常为线性加权
    En_comp = sqrt(sum(En_values.^2 .* weights)); % 熵的聚合方式（方差可加性）
    He_comp = sqrt(sum(He_values.^2 .* weights)); % 超熵的聚合方式
    
    comp_cloud = struct('Ex', Ex_comp, 'En', En_comp, 'He', He_comp);
end

% --- 其他辅助函数保持不变 ---
function normalized_data = normalize_data_hybrid(data_matrix, types, thresholds)
    [n_samples, n_indicators] = size(data_matrix);
    normalized_data = zeros(n_samples, n_indicators);

    for j = 1:n_indicators
        col_data = data_matrix(:, j);
        threshold = thresholds{j};
        type = types{j};

        if isempty(threshold)
            min_val = min(col_data); max_val = max(col_data);
            range = max_val - min_val; if range == 0; range = 1; end
            if strcmp(type, 'positive')
                normalized_data(:, j) = (col_data - min_val) / range * 100;
            else
                normalized_data(:, j) = (max_val - col_data) / range * 100;
            end
        else
            C_min = threshold(1); C_max = threshold(2);
            range = C_max - C_min; if range == 0; range = 1; end
            if strcmp(type, 'positive')
                temp_data = (col_data - C_min) / range * 100;
            else
                temp_data = (C_max - col_data) / range * 100;
            end
            normalized_data(:, j) = max(0, min(100, temp_data));
        end
    end
end

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

function standard_clouds = build_standard_clouds(labels, intervals)
    num_levels = length(labels);
    standard_clouds = struct('Ex', cell(1,num_levels), 'En', cell(1,num_levels), 'He', cell(1,num_levels), 'Label', cell(1,num_levels));
    for i = 1:num_levels
        C_min = intervals{i}(1); C_max = intervals{i}(2);
        standard_clouds(i).Ex = (C_min + C_max) / 2;
        standard_clouds(i).En = (C_max - C_min) / 6;
        standard_clouds(i).He = standard_clouds(i).En / 10;
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
    num_drops = 3000;
    En_prime = normrnd(standard_cloud.En, standard_cloud.He, [1, num_drops]);
    En_prime(En_prime<0) = 0; % 熵不能为负
    mu_denom = 2 * En_prime.^2;
    mu_denom(mu_denom==0) = 1e-6; % 避免除以零
    mu_values = exp(-(score - standard_cloud.Ex).^2 ./ mu_denom);
    sim = mean(mu_values);
end
