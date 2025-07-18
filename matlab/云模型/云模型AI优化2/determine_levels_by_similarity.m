% determine_levels_by_similarity.m
function [levels, sim_matrix] = determine_levels_by_similarity(scores, standard_clouds)
    % 输入:
    %   scores: 每个钻孔的综合得分 (n x 1 向量)
    %   standard_clouds: 标准等级云的结构体数组
    % 输出:
    %   levels: 每个钻孔最终的等级索引 (n x 1 向量)
    %   sim_matrix: 每个钻孔与每个等级的相似度矩阵 (n x k)

    num_samples = length(scores);
    num_levels = length(standard_clouds);
    
    % 创建一个矩阵来存储每个样本与每个标准云的相似度
    sim_matrix = zeros(num_samples, num_levels);
    
    % 设置模拟参数
    N_drops = 1000;  % 为每个钻孔生成1000个云滴进行模拟
    En_j = 1e-5;     % 待评价样本的熵，设为一个极小值
    He_j = 1e-6;     % 待评价样本的超熵，设为一个更小的值

    for i = 1:num_samples
        % 获取当前钻孔的云模型 (Ex为综合得分, En和He为极小值)
        Ex_j = scores(i);
        
        % 1. 生成钻孔的云滴
        En_prime = normrnd(En_j, He_j, 1, N_drops);
        En_prime(En_prime < 0) = 0;
        drops_j = normrnd(Ex_j, En_prime, 1, N_drops);
        
        % 遍历所有标准等级云
        for k = 1:num_levels
            % 获取当前标准云的参数
            Ex_k = standard_clouds(k).Ex;
            En_k = standard_clouds(k).En;
            
            % 2. 计算所有云滴在当前标准云中的隶属度
            mu_k_values = exp(-(drops_j - Ex_k).^2 ./ (2 * En_k^2));
            
            % 3. 计算期望隶属度，即相似度
            sim_matrix(i, k) = mean(mu_k_values);
        end
    end
    
    % 4. 找到每一行中最大相似度的索引，即为最终等级
    [~, levels] = max(sim_matrix, [], 2);
end
