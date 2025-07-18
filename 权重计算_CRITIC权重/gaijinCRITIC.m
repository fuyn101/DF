% 导入数据#%%CRITIC法
[numData, txtData, rawData] = xlsread('C:\Users\admin\Desktop\211评估方法\特征数据.xls');
label_need = txtData(1, 2:end); % 所需的标签
data1 = numData(:, 2:end); % 获取对应的数值数据

[m, n] = size(data1); % 获取行数和列数
data2 = data1;

% 负向指标标准化
index = 3; % 负向指标位置
fprintf('负向指标数据\n');
disp(data1(:, index));
d_max = max(data1(:, index));
d_min = min(data1(:, index));
data2(:, index) = (d_max - data1(:, index)) / (d_max - d_min);

% 正向指标标准化
index_all = 1:n;
index = setdiff(index_all, index);
for j = index
    fprintf('正向指标数据\n');
    disp(data1(:, j));
    d_max = max(data1(:, j));
    d_min = min(data1(:, j));
    data2(:, j) = (data1(:, j) - d_min) / (d_max - d_min);
end

% 对比性
the = std(data2);
fprintf('各指标标准差:\n');
disp(the);
PJ = mean(data2);
fprintf('各指标平均值:\n');
disp(PJ);
BYXS = the ./ PJ;
fprintf('各指标变异系数:\n');
disp(BYXS);

% 矛盾性
r = corr(data2); % 皮尔逊相关系数
f = sum(1 - r, 2)';
fprintf('各指标相关冲突性:\n');
disp(f);

% 信息承载量
c = the .* f;

% 计算权重
w = c / sum(c);
fprintf('未改进的CRITIC权重:\n');
disp(w);
GJCRITIC = BYXS .* f;
GJDQ = GJCRITIC / sum(GJCRITIC);
fprintf('改进CRITIC指标权重:\n');
disp(GJDQ);

% 计算得分
s = data2 * w';
Score = s / max(s);
disp(s);

% 如果需要保存得分到Excel，取消以下注释
% T = array2table(s, 'VariableNames', {'综合评价值'});
% writetable(T, 'D:\\lunwen\\线性加权.xls', 'Sheet', 'topsis综合贴进度');