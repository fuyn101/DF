function combined_weights = combined_weighting(ahp_weights, critic_weights)
% 组合权重计算函数
% 输入:
%  主观权重向量 (1×n)
%  客观权重向量 (1×n)
% 输出:
%   combined_weights - 组合权重向量 (1×n)

% 验证输入
if nargin < 2
    error('需要两个权重向量作为输入');
end

if length(ahp_weights) ~= length(critic_weights)
    error('权重向量长度不一致');
end

% 计算几何平均值
geo_mean = sqrt(ahp_weights .* critic_weights);

% 归一化得到组合权重
combined_weights = geo_mean / sum(geo_mean);

% 验证结果
if abs(sum(combined_weights) - 1) > 1e-6
    warning('权重和不为1，请检查输入');
end

% 可视化权重比较
figure;
subplot(3,1,1);
bar(ahp_weights, 'b');
title('AHP主观权重');
ylim([0, max([ahp_weights, critic_weights])*1.2]);

subplot(3,1,2);
bar(critic_weights, 'r');
title('CRITIC客观权重');
ylim([0, max([ahp_weights, critic_weights])*1.2]);

subplot(3,1,3);
bar(combined_weights, 'g');
title('组合权重');
ylim([0, max([ahp_weights, critic_weights])*1.2]);

% 输出权重对比表
fprintf('权重对比:\n');
fprintf('指标\t AHP权重\t CRITIC权重\t 组合权重\n');
for i = 1:length(ahp_weights)
    fprintf('%d\t %.4f\t\t %.4f\t\t %.4f\n', i, ahp_weights(i), critic_weights(i), combined_weights(i));
end

% 计算组合效果指标
ahp_divergence = sum(combined_weights .* log(combined_weights ./ ahp_weights));
critic_divergence = sum(combined_weights .* log(combined_weights ./ critic_weights));

fprintf('\n组合效果评估:\n');
fprintf('与AHP权重的KL散度: %.6f\n', ahp_divergence);
fprintf('与CRITIC权重的KL散度: %.6f\n', critic_divergence);
fprintf('总相对熵: %.6f\n', ahp_divergence + critic_divergence);
end
% 假设已计算得到AHP权重和CRITIC权重
ahp_weights = [0.3076, 0.3076, 0.1790, 0.0879, 0.0890, 0.0288];    % AHP主观权重
critic_weights = [0.1544, 0.1225, 0.1368, 0.2159, 0.1615, 0.2088]; % CRITIC客观权重

% 计算组合权重
combined_weights = combined_weighting(ahp_weights, critic_weights);

% 显示结果
disp('组合权重结果:');
disp(combined_weights);