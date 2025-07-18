%% TOPSIS综合评价方法实现
clc; clear; close all;

%% 1. 数据读取与预处理
disp('===== 1. 数据读取与预处理 =====');
% 读取Excel数据（假设第一列为评价对象名称，后面为评价指标）
[filename, pathname] = uigetfile('*.xlsx', '选择数据文件');

% 这样可以确保即使Excel没有标题行，第一行数据也能被正确读取
data = readtable(fullfile(pathname, filename), 'ReadVariableNames', false);

% 提取数据
objectNames = data{:, 1};          % 评价对象名称
evalData = data{:, 2:end};         % 评价指标数据
[n, m] = size(evalData);           % n:评价对象数量, m:指标数量

disp('评价对象名称:');
disp(objectNames);
disp('原始评价数据:');
disp(evalData);
fprintf('评价对象数量: %d, 评价指标数量: %d\n', n, m);

%% 2. 指标类型判断
disp('===== 2. 指标类型判断 =====');
% 创建指标类型数组 (1:效益型, 2:成本型)
indicatorTypes = zeros(1, m);

for i = 1:m
    % 由于没有读取标题行，这里使用通用提示
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
% 向量归一化
normalizedData = evalData ./ sqrt(sum(evalData.^2));

disp('标准化后的数据:');
disp(normalizedData);

%% 4. 序关系分析法(G1法)确定主观权重
disp('===== 4. 序关系分析法(G1法)确定主观权重 =====');
% 让专家对指标重要性排序
disp('请专家对指标按重要性从高到低排序(输入指标编号1~m):');
rankOrder = zeros(1, m);
for i = 1:m
    prompt = sprintf('请输入第%d重要的指标编号(1~%d): ', i, m);
    rankOrder(i) = input(prompt);
    while ~ismember(rankOrder(i), 1:m) || ismember(rankOrder(i), rankOrder(1:i-1))
        disp('输入错误或重复，请重新输入');
        rankOrder(i) = input(prompt);
    end
end

disp('指标重要性排序:');
disp(rankOrder);

% 输入相邻指标重要性比较值r_k
r = zeros(1, m);
for k = 2:m
    prompt = sprintf('请输入r_%d (指标%d相对于指标%d的重要性比值, 建议1.0-1.8): ', k, rankOrder(k-1), rankOrder(k));
    r(k) = input(prompt);
    while r(k) < 1.0 || r(k) > 1.8
        disp('输入超出建议范围(1.0-1.8)，请重新输入');
        r(k) = input(prompt);
    end
end

% 计算主观权重
w_subjective = zeros(1, m);
w_subjective(rankOrder(m)) = 1; % 最不重要指标的权重设为1

for k = m:-1:2
    w_subjective(rankOrder(k-1)) = r(k) * w_subjective(rankOrder(k));
end

w_subjective = w_subjective / sum(w_subjective); % 归一化

disp('主观权重(G1法):');
disp(w_subjective);

%% 5. CRITIC法确定客观权重
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

%% 6. 组合权重计算 (基于最小信息熵原理的乘法合成法)
disp('===== 6. 组合权重计算 =====');
% 该方法基于最小相对信息熵原理，通过拉格朗日乘子法推导得出。
% 它通过几何平均的方式组合主观权重和客观权重，无需手动设置偏好系数。
% 公式为: W_j = sqrt(w_subjective_j * w_objective_j) / sum(sqrt(w_subjective_j * w_objective_j))

% 计算主客观权重的几何平均值作为分子
numerator = sqrt(w_subjective .* w_objective);

% 归一化得到最终组合权重
w_combined = numerator / sum(numerator);

disp('组合权重 (乘法合成法):');
disp(w_combined);


%% 7. TOPSIS计算
disp('===== 7. TOPSIS计算 =====');
% 构建加权标准化决策矩阵
weightedData = normalizedData .* w_combined;

% 确定正理想解和负理想解
positive_ideal = zeros(1, m);
negative_ideal = zeros(1, m);

for i = 1:m
    if indicatorTypes(i) == 1 % 效益型
        positive_ideal(i) = max(weightedData(:, i));
        negative_ideal(i) = min(weightedData(:, i));
    else % 成本型
        positive_ideal(i) = min(weightedData(:, i));
        negative_ideal(i) = max(weightedData(:, i));
    end
end

disp('正理想解:');
disp(positive_ideal);
disp('负理想解:');
disp(negative_ideal);

% 计算各方案到正负理想解的距离
D_plus = sqrt(sum((weightedData - positive_ideal).^2, 2));
D_minus = sqrt(sum((weightedData - negative_ideal).^2, 2));

% 计算相对接近度
C = D_minus ./ (D_plus + D_minus);

disp('各方案到正理想解的距离(D+):');
disp(D_plus);
disp('各方案到负理想解的距离(D-):');
disp(D_minus);
disp('相对接近度(C):');
disp(C);

%% 8. 结果排序与输出
disp('===== 8. 结果排序与输出 =====');
% 按相对接近度降序排序
[~, rankIndex] = sort(C, 'descend');

% 显示排序结果
fprintf('\n最终评价结果排序:\n');
fprintf('排名\t对象名称\t相对接近度\n');
for i = 1:n
    % --- 修改之处：使用花括号{}来提取cell单元的内容 ---
    fprintf('%d\t%s\t%.4f\n', i, objectNames{rankIndex(i)}, C(rankIndex(i)));
end

% 绘制结果柱状图
figure;
barh(C(rankIndex));
% --- 同样，为Y轴标签提取cell内容，这是最保险的做法 ---
set(gca, 'YTick', 1:n, 'YTickLabel', objectNames(rankIndex), 'YDir', 'reverse');
title('TOPSIS评价结果');
xlabel('相对接近度');
ylabel('评价对象');
grid on;
