% K-means clustering for each indicator in the dataset

% 1. 读取CSV文件
% 假设CSV文件和这个脚本在同一个目录下，或者提供完整/相对路径
filename = '评价方法_云模型前置_多指标K均值聚类/云模型数据.csv';

% 使用readtable读取数据，它可以很好地处理带有表头的文件
% 'ReadVariableNames' 设置为 true（默认）来读取表头
% 'VariableNamingRule' 设置为 'preserve' 以使用原始列标题
% 'Encoding' 设置为 'UTF-8' 以正确读取中文字符

T = readtable(filename, 'Encoding', 'UTF-8', 'VariableNamingRule', 'preserve');



% 提取数值数据，从第2列到最后一列（忽略第一列的钻孔编号）
data = T{:, 2:end};

% 获取指标名称
indicatorNames = T.Properties.VariableNames(2:end);

% 2. 对每个指标进行标准化和K-means聚类
% size(data, 2) 获取数据矩阵的列数，即指标的总数
numIndicators = size(data, 2);
k = 4; % 设定聚类数量

fprintf('开始对每个指标进行 K-means 聚类 (k=%d)...\n\n', k);

% 创建一个单元格数组来存储每个指标的聚类中心和标准化数据
all_centers = cell(1, numIndicators);
all_normalized_data = cell(1, numIndicators);

for i = 1:numIndicators
    % 提取当前指标的列数据
    indicatorData = data(:, i);
    
    % a. 标准化到 [0, 1] 区间
    minVal = min(indicatorData);
    maxVal = max(indicatorData);
    
    % 避免除以零的情况（如果列中所有值都相同）
    if maxVal == minVal
        normalizedData = ones(size(indicatorData, 1), 1) * 0.5; % 或者全为0，或全为1
    else
        normalizedData = (indicatorData - minVal) / (maxVal - minVal);
    end
    
    % b. 对标准化后的一维数据执行 K-means 聚类
    % kmeans 函数需要数据是 n*p 矩阵, 这里 p=1
    % 'Start', 'uniform' 在一维数据上效果很好
    % 'Replicates', 5 多次运行以找到最佳结果
    [~, centers] = kmeans(normalizedData, k, 'Replicates', 100, 'Start', 'uniform');
    
    % c. 输出聚类中心
    
    fprintf('指标 "%s" 的聚类中心 (标准化后):\n', indicatorNames{i});
    % 排序后转置输出，使其显示为一行，更易读
    disp(sort(centers)');
    
    % 存储排序后的聚类中心和标准化数据
    all_centers{i} = sort(centers);
    all_normalized_data{i} = normalizedData;
end

% 提示任务完成
fprintf('\n所有指标的K-means聚类中心已计算并显示。\n');

% 3. 将结果保存到CSV文件
% a. 保存标准化后的数据
% 使用 array2table 直接从数值矩阵创建表
normalized_matrix = horzcat(all_normalized_data{:});
normalized_table = array2table(normalized_matrix, 'VariableNames', indicatorNames);
writetable(normalized_table, '评价方法_云模型前置_多指标K均值聚类/normalized_data.csv');
fprintf('标准化后的数据已保存到 "normalized_data.csv"\n');

% b. 保存聚类中心
centers_matrix = horzcat(all_centers{:});
centers_table = array2table(centers_matrix, 'VariableNames', indicatorNames);
writetable(centers_table, '评价方法_云模型前置_多指标K均值聚类/cluster_centers.csv');
fprintf('聚类中心已保存到 "cluster_centers.csv"\n');


% 如果需要，可以将结果保存到.mat文件以供后续使用
% save('kmeans_cluster_centers.mat', 'all_centers', 'indicatorNames');
