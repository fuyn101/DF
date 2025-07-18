% 定义两个权重向量
ahp_weights = [0.3508, 0.1898, 0.2506, 0.2088];
critic_weights = [0.282353039255571	0.200273137765936	0.262731993840209	0.254641829138285];

% 调用函数计算组合权重
combined_w_2 = flexible_combined_weighting(ahp_weights, critic_weights);

% 显示命令行中的结果
disp('两个向量的组合权重结果:');
disp(combined_w_2);
