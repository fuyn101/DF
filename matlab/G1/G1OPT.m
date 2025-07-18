% =================== 推荐的修正和优化 ===================
clear all; % 彻底清除工作区，避免变量名冲突
clc;       % 清空命令行窗口

% =================== 你需要修改的部分 ===================
% 1. 定义你的指标排序关系
% 例如: 指标1最重要，其次是指标2，然后是指标4...
p_relationship = [1, 2, 4, 5, 3, 6]; 

% 2. 定义排序后，相邻指标的重要性比值
% p_relative(k) = (第k重要指标的权重) / (第k+1重要指标的权重)
% 值的含义参考: 1.0=同等重要, 1.2=稍微重要, 1.4=明显重要, 1.6=非常重要, 1.8=极端重要
p_relative = [1, 1.4, 1.2, 1, 1.2];
% ==========================================================


% =================== 通用计算代码（无需修改）==============
% 获取指标数量
num_indicators = length(p_relationship);

% 检查输入是否合法
if length(p_relative) ~= num_indicators - 1
    error('p_relative 向量的长度必须是指标数量减一!');
end

% 初始化权重向量
p_weight_sorted = zeros(1, num_indicators);
p_final_weights = zeros(1, num_indicators);

% p权重计算 (排序后的权重)
p_relative_sum = 0;
for k = 2:num_indicators
   p_relative_multiply = 1;
   for j = k:num_indicators
       p_relative_multiply = p_relative_multiply * p_relative(j-1);
   end
   p_relative_sum = p_relative_sum + p_relative_multiply;
end

% 计算最不重要的指标的权重
p_weight_sorted(num_indicators) = 1 / (1 + p_relative_sum);

% 反向计算其他指标的权重
for k = (num_indicators-1):-1:1
    p_weight_sorted(k) = p_weight_sorted(k+1) * p_relative(k);
end

% 将排序后的权重映射回原始指标顺序
for i = 1:num_indicators
    original_index = p_relationship(i);
    p_final_weights(original_index) = p_weight_sorted(i);
end

% 显示结果
disp('按重要性排序后的权重 (p_weight_sorted):');
disp(p_weight_sorted);

disp('映射回原始顺序的最终权重 (p_final_weights):');
disp(p_final_weights);

% 检查权重总和是否为1 (用于验证)
fprintf('权重总和: %f\n', sum(p_final_weights));

