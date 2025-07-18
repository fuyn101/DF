function dynamic_weights = incentivePunishmentVariableWeight(X_samples, config, calibration)
% incentivePunishmentVariableWeight - 计算基于激励-惩罚函数的状态变权
%
% 本函数整合了模型参数计算和动态权重计算两个步骤，提供了一个完整的、
% 从输入到输出的解决方案。
%
% 输入:
%   X_samples:   待评估的样本矩阵 (样本数 x 指标数)
%   config:      包含模型核心配置的结构体
%                - config.constant_weights: 常数权重向量 (1 x n)
%                - config.d_intervals: 变权区间矩阵 (n x 3)
%   calibration: 包含标定所需参数的结构体
%                - calibration.ideal_weights: 理想权重向量 (1 x n)
%                - calibration.sample: 标定样本向量 (1 x n)
%                - calibration.indices: 标定指标索引结构体
%
% 输出:
%   dynamic_weights: 最终的动态权重矩阵 (样本数 x 指标数)，如果计算失败则返回空矩阵

%% 第1步: 验证输入
if abs(sum(config.constant_weights) - 1) > 1e-6
    warning('常数权重(config.constant_weights)之和不为1，可能导致结果不符合预期！');
end

%% 第2步: 计算模型参数 (内嵌逻辑)
model_params = calculate_params_inline(config, calibration);

% 检查参数是否求解成功
if isempty(model_params)
    dynamic_weights = []; % 如果求解失败，返回空矩阵
    return;
end

% 显示计算出的参数
fprintf('模型参数计算成功:\n');
fprintf('    c  = %.4f\n', model_params.c);
fprintf('    a1 = %.4f (惩罚区系数)\n', model_params.a1);
fprintf('    a2 = %.4f (激励区系数)\n', model_params.a2);
fprintf('    a3 = %.4f (强激励区系数)\n\n', model_params.a3);

%% 第3步: 计算动态权重 (内嵌逻辑)
dynamic_weights = calculate_weights_inline(X_samples, config, model_params);

end


% =========================================================================
% 内嵌函数: 计算模型参数
% =========================================================================
function params = calculate_params_inline(config, calibration)
% 从 config 和 calibration 结构体中提取参数
w0 = config.constant_weights;
d = config.d_intervals;
w = calibration.ideal_weights;
x = calibration.sample;
calib_indices = calibration.indices;

params = []; % 初始化

p_idx = calib_indices.punish;
n_idx = calib_indices.neutral;
i_idx = calib_indices.incentive;
si_idx = calib_indices.strong_incentive;

k3 = 2; % 简化模型，设为常数

a = length(w0);
all_indices = 1:a;
calib_set = [p_idx, n_idx, i_idx, si_idx];
other_indices = setdiff(all_indices, calib_set);

k1 = (w0(n_idx) - w0(n_idx)*sum(w(calib_set)) - w(n_idx)*sum(w0(other_indices))) / (w(n_idx)*w0(p_idx));
k2 = (w(p_idx)*w0(n_idx) - w(n_idx)*w0(p_idx)) / (w(n_idx)*w0(p_idx));

syms c_sym
eqn = k1 * c_sym == (k2 * c_sym + 1)^k3 - 1;

try
    c_val = vpasolve(eqn, c_sym);
    c_val = double(c_val);
    c_val = c_val(c_val > 0 & imag(c_val)==0);
    if isempty(c_val)
        error('方程没有找到正实数解 for c.');
    end
    c = c_val(1);
catch ME
    fprintf('错误: 无法求解参数c。\n');
    fprintf('原因: %s\n', ME.message);
    fprintf('请检查您的标定参数(w0, w, x, d)是否合理。\n');
    return;
end

a1 = (1/(d(p_idx,1) - x(p_idx))) * log( ((w(p_idx)*w0(n_idx) - w(n_idx)*w0(p_idx)) / (w(n_idx)*w0(p_idx)))*c + 1);
a2 = (1/(x(i_idx) - d(i_idx,2))) * log( ((w(i_idx)*w0(n_idx) - w(n_idx)*w0(i_idx)) / (w(n_idx)*w0(i_idx)))*c + 1);
a3 = (1/(x(si_idx) - d(si_idx,3))) * log( ((w(si_idx)*w0(n_idx) - w(n_idx)*w0(si_idx)) / (w(n_idx)*w0(si_idx)))*c + 2 ...
    - ( ((w(i_idx)*w0(n_idx) - w(n_idx)*w0(i_idx)) / (w(n_idx)*w0(i_idx)))*c + 1 )^((d(si_idx,3) - d(si_idx,2))/(x(i_idx) - d(i_idx,2))) );

params.c = c;
params.a1 = real(a1);
params.a2 = real(a2);
params.a3 = real(a3);
end

% =========================================================================
% 内嵌函数: 计算动态权重
% =========================================================================
function weights = calculate_weights_inline(X, config, model_params)
% 从 config 和 model_params 结构体中提取参数
w0 = config.constant_weights;
d = config.d_intervals;
c = model_params.c;
a1 = model_params.a1;
a2 = model_params.a2;
a3 = model_params.a3;

[num_samples, num_indicators] = size(X);
state_values = zeros(num_samples, num_indicators);

for i = 1:num_samples
    for j = 1:num_indicators
        x_val = X(i, j);
        
        if x_val >= 0 && x_val < d(j, 1)
            state_values(i, j) = exp(a1 * (d(j, 1) - x_val)) + c - 1;
        elseif x_val >= d(j, 1) && x_val < d(j, 2)
            state_values(i, j) = c;
        elseif x_val >= d(j, 2) && x_val < d(j, 3)
            state_values(i, j) = exp(a2 * (x_val - d(j, 2))) + c - 1;
        elseif x_val >= d(j, 3) && x_val <= 1
            term1 = exp(a3 * (x_val - d(j, 3)));
            term2 = exp(a2 * (d(j, 3) - d(j, 2)));
            state_values(i, j) = term1 + term2 + c - 2;
        else
            state_values(i, j) = c;
        end
    end
end

unnormalized_weights = w0 .* state_values;
sum_weights = sum(unnormalized_weights, 2);
weights = unnormalized_weights ./ sum_weights;
end
