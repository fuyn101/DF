%% 综合评价主脚本
clc; clear; close all;

%% 1. 数据读取与预处理
disp('===== 1. 数据读取与预处理 =====');
[filename, pathname] = uigetfile('*.xlsx', '选择数据文件');
data = readtable(fullfile(pathname, filename), 'ReadVariableNames', false);
objectNames = data{:, 1};
evalData = data{:, 2:end};
[n, m] = size(evalData);
disp('评价对象名称:');
disp(objectNames);
disp('原始评价数据:');
disp(evalData);
fprintf('评价对象数量: %d, 评价指标数量: %d\n', n, m);

%% 2. 指标类型判断
disp('===== 2. 指标类型判断 =====');
indicatorTypes = zeros(1, m);
for i = 1:m
    prompt = sprintf('指标%d 类型: 1-效益型(越大越好), 2-成本型(越小越好)? ', i);
    indicatorTypes(i) = input(prompt);
    while ~ismember(indicatorTypes(i), [1, 2])
        disp('输入错误，请输入1或2');
        indicatorTypes(i) = input(prompt);
    end
end
disp('各指标类型 (1:效益型, 2:成本型):');
disp(indicatorTypes);

%% 3. 数据标准化处理
disp('===== 3. 数据标准化处理 =====');
normalizedData = evalData ./ sqrt(sum(evalData.^2));
disp('标准化后的数据:');
disp(normalizedData);

%% 4. 确定主观权重 (G1法)
w_subjective = G1_fang(m);

%% 5. 确定客观权重 (CRITIC法)
w_objective = critic_fang(normalizedData);

%% 6. 组合权重计算
disp('===== 6. 组合权重计算 =====');
numerator = sqrt(w_subjective .* w_objective);
w_combined = numerator / sum(numerator);
disp('组合权重 (乘法合成法):');
disp(w_combined);

%% 7. TOPSIS计算与结果输出
topsis_fang(normalizedData, w_combined, indicatorTypes, objectNames);
