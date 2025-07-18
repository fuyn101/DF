% calculate_scores.m
function scores = calculate_scores(norm_data, weights)
    % 确保权重是列向量以便进行矩阵乘法
    if size(weights, 2) > 1
        weights = weights';
    end
    scores = norm_data * weights;
end
