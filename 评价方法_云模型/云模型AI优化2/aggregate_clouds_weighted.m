% aggregate_clouds_weighted.m
function comp_cloud = aggregate_clouds_weighted(indicator_clouds, weights)
    % 输入:
    %   indicator_clouds: 1 x n 的指标云结构体数组 {Ex, En, He}
    %   weights: 1 x n 的权重向量
    % 输出:
    %   comp_cloud: 包含{Ex, En, He}的单个综合云结构体

    % 确保权重归一化
    weights = weights(:)' / sum(weights);

    % 提取所有指标云的 Ex, En, He 到向量中
    Ex_vec = [indicator_clouds.Ex];
    En_vec = [indicator_clouds.En];
    He_vec = [indicator_clouds.He];

    % 使用加权平均法进行聚合
    Ex_comp = sum(weights .* Ex_vec);
    En_comp = sum(weights .* En_vec);
    He_comp = sum(weights .* He_vec);

    comp_cloud.Ex = Ex_comp;
    comp_cloud.En = En_comp;
    comp_cloud.He = He_comp;
end
