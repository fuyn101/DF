function [p_final_weights, p_weight_sorted] = calculateG1Weights(p_relationship, p_relative)
%calculateG1Weights - 根据G1方法计算权重
%
%   详细说明:
%   该函数根据G1法（序关系分析法）的原理，通过指标的重要性排序 (p_relationship)
%   和相邻指标的相对重要性比值 (p_relative) 来计算最终的指标权重。
%
%   输入参数:
%       p_relationship - (1xN 向量) 定义N个指标的重要性排序。
%                        例如: [1, 2, 4, 5, 3, 6] 表示指标1最重要，其次是2, 4, 5, 3, 6。
%       p_relative     - (1x(N-1) 向量) 定义排序后，相邻指标的重要性比值。
%                        p_relative(k) = (第k重要指标的权重) / (第k+1重要指标的权重)。
%                        建议取值: 1.0 (同等重要), 1.2 (稍微重要), 1.4 (明显重要),
%                        1.6 (非常重要), 1.8 (极端重要)。
%
%   输出参数:
%       p_final_weights - (1xN 向量) 返回与原始指标顺序对应的最终权重。
%                         例如 p_final_weights(1) 是指标1的权重。
%       p_weight_sorted - (1xN 向量) 返回按重要性排序的权重。
%
%   调用示例:
%       p_relationship = [1, 2, 4, 5, 3, 6];
%       p_relative = [1, 1.4, 1.2, 1, 1.2];
%       [weights, sorted_weights] = calculateG1Weights(p_relationship, p_relative);

% 获取指标数量
num_indicators = length(p_relationship);

% 检查输入是否合法
if length(p_relative) ~= num_indicators - 1
    error('输入错误: p_relative 向量的长度必须是指标数量减一!');
end

% 初始化权重向量
p_weight_sorted = zeros(1, num_indicators);
p_final_weights = zeros(1, num_indicators);

% --- 核心计算逻辑 (重构后更清晰) ---

% 根据 r_k = w_k / w_{k+1} 的关系，所有权重都可以表示为最不重要权重 w_n 的倍数。
% w_k / w_n = r_k * r_{k+1} * ... * r_{n-1}
% 权重和为1: sum(w_k) = 1 => w_n * sum(w_k / w_n) = 1
% 因此，w_n = 1 / sum(w_k / w_n)

% 1. 计算每个权重相对于最不重要权重 w_n 的比值 (w_k / w_n)
w_ratios = ones(1, num_indicators); % 初始化 w_ratios(k) = w_k / w_n
% 从后往前计算，w_n/w_n = 1 已经设置好
for k = (num_indicators - 1):-1:1
    % (w_k / w_n) = (w_k / w_{k+1}) * (w_{k+1} / w_n)
    w_ratios(k) = p_relative(k) * w_ratios(k+1);
end

% 2. 计算分母，即所有比值之和
denominator = sum(w_ratios);

% 3. 计算最不重要的指标的权重 w_n
p_weight_sorted(num_indicators) = 1 / denominator;

% 4. 反向递推计算其他指标的权重
for k = (num_indicators - 1):-1:1
    p_weight_sorted(k) = p_weight_sorted(k+1) * p_relative(k);
end

% 5. 将排序后的权重映射回原始指标顺序
for i = 1:num_indicators
    original_index = p_relationship(i);
    p_final_weights(original_index) = p_weight_sorted(i);
end

end
