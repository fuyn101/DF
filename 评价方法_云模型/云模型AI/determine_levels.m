% determine_levels.m
function [levels, sub_matrix] = determine_levels(scores, clouds)
    num_samples = length(scores);
    num_levels = length(clouds);
    
    % 创建一个矩阵来存储每个样本对每个等级的隶属度
    sub_matrix = zeros(num_samples, num_levels);
    
    for k = 1:num_levels
        Ex = clouds(k).Ex;
        En = clouds(k).En;
        
        % 使用向量化计算，一次性算出所有样本对当前等级的隶属度
        sub_matrix(:, k) = exp(-(scores - Ex).^2 ./ (2 * En^2));
    end
    
    % 找到每一行中最大值的索引，这个索引就是评价等级
    [~, levels] = max(sub_matrix, [], 2);
end
