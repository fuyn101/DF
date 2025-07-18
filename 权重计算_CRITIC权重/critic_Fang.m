function w_objective = CRITIC_fang(normalizedData)
% critic_fang.m: 使用CRITIC方法计算客观权重
% 输入:
%   normalizedData - 标准化后的数据矩阵 (n个评价对象, m个指标)
% 输出:
%   w_objective    - 客观权重向量 (1 x m)

disp('===== 5. CRITIC法确定客观权重 =====');

% 计算标准差
std_dev = std(normalizedData);

% 计算相关系数矩阵
corr_matrix = corr(normalizedData);

% 计算冲突性指标
conflict = sum(1 - corr_matrix);

% 计算信息量
information = std_dev .* conflict;

% 计算客观权重
w_objective = information / sum(information);

disp('各指标标准差:');
disp(std_dev);
disp('相关系数矩阵:');
disp(corr_matrix);
disp('冲突性指标:');
disp(conflict);
disp('信息量:');
disp(information);
disp('客观权重(CRITIC法):');
disp(w_objective);

end
