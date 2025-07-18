function topsis_fang(normalizedData, w_combined, indicatorTypes, objectNames)
% topsis_fang.m: 使用TOPSIS方法进行综合评价并输出结果
% 输入:
%   normalizedData - 标准化后的数据矩阵 (n x m)
%   w_combined     - 组合权重向量 (1 x m)
%   indicatorTypes - 指标类型向量 (1 x m), 1:效益型, 2:成本型
%   objectNames    - 评价对象名称 (n x 1 cell)

disp('===== 7. TOPSIS计算 =====');
[n, m] = size(normalizedData);

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
    fprintf('%d\t%s\t%.4f\n', i, objectNames{rankIndex(i)}, C(rankIndex(i)));
end

% 绘制结果柱状图
figure;
barh(C(rankIndex));
set(gca, 'YTick', 1:n, 'YTickLabel', objectNames(rankIndex), 'YDir', 'reverse');
title('TOPSIS评价结果');
xlabel('相对接近度');
ylabel('评价对象');
grid on;

end
