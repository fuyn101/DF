function dynamic_weights = calculateDynamicWeights(X, w0, d, params)
% calculateDynamicWeights - 应用状态变权模型计算最终的动态权重
%
% 输入:
%   X:      待评估的样本矩阵 (样本数 x 指标数)
%   w0:     常数权重向量 (1 x 指标数)
%   d:      变权区间矩阵 (指标数 x 3)
%   params: 包含模型参数c, a1, a2, a3的结构体
%
% 输出:
%   dynamic_weights: 最终的动态权重矩阵 (样本数 x 指标数)

    % 解包参数
    c = params.c;
    a1 = params.a1;
    a2 = params.a2;
    a3 = params.a3;

    [num_samples, num_indicators] = size(X);
    state_values = zeros(num_samples, num_indicators); % 变权向量 S

    % 遍历每个样本的每个指标，计算原始状态权值 S(i,j)
    for i_sample = 1:num_samples
        for j_indicator = 1:num_indicators
            x_val = X(i_sample, j_indicator);
            
            % 根据样本值所在的区间，使用对应的变权函数
            if x_val >= 0 && x_val < d(j_indicator, 1) % 惩罚区
                state_values(i_sample, j_indicator) = exp(a1 * (d(j_indicator, 1) - x_val)) + c - 1;
            elseif x_val >= d(j_indicator, 1) && x_val < d(j_indicator, 2) % 中性区
                state_values(i_sample, j_indicator) = c;
            elseif x_val >= d(j_indicator, 2) && x_val < d(j_indicator, 3) % 激励区
                state_values(i_sample, j_indicator) = exp(a2 * (x_val - d(j_indicator, 2))) + c - 1;
            elseif x_val >= d(j_indicator, 3) && x_val <= 1 % 强激励区
                term1 = exp(a3 * (x_val - d(j_indicator, 3)));
                term2 = exp(a2 * (d(j_indicator, 3) - d(j_indicator, 2)));
                state_values(i_sample, j_indicator) = term1 + term2 + c - 2;
            else
                % 处理超出[0,1]范围的值，可以设为中性或给出警告
                state_values(i_sample, j_indicator) = c; 
            end
        end
    end

    % 计算未归一化的权重 (W_S = w0 * S)
    unnormalized_weights = w0 .* state_values;

    % 归一化，得到最终的动态权重
    sum_weights_per_sample = sum(unnormalized_weights, 2);
    dynamic_weights = unnormalized_weights ./ sum_weights_per_sample;
end
