% -------------------------------------------------------------------------
%   文件: R3JDJMD.m
%   功能: 计算每个网格与断层线的相交次数及断层尖灭点数量
%   作者: Cline
%   日期: 2025-07-16
%
%   输入:
%       - 网格数据文件 (CSV格式, e.g., '分维值结果_*.csv')
%         - 'Geo X Min (m)', 'Geo X Max (m)', 'Geo Y Min (m)', 'Geo Y Max (m)'
%       - 断层数据文件夹 (e.g., '平禹断层数据')
%         - 包含多个CSV文件，每个文件代表一条断层线
%         - 每个文件需包含 'X' 和 'Y' 两列
%
%   输出:
%       - 'grid_polygon_intersection_counts.csv': 包含以下列的CSV文件
%         - 网格原始数据
%         - 'polygon_intersection_count': 每个网格与断层线的相交次数
%         - 'tip_point_count': 每个网格内的断层尖灭点数量
%
%   依赖:
%       - MATLAB R2016b or later
%
%   用法:
%       直接在MATLAB中运行此脚本。确保输入文件和目录结构正确。
% -------------------------------------------------------------------------

% 主函数，用于计算每个网格与多少个断层线相交，并统计断层尖灭点
clear;
clc;
% --- 配置 ---
grid_file_pattern = '分维值_密度.csv'; % 网格文件模式
fault_data_dir = '新的断层数据'; % 断层数据目录
output_file = '分维值_密度_尖灭点.csv'; % 输出文件

% --- 1. 读取网格数据 ---
grid_files = dir(grid_file_pattern);
if isempty(grid_files)
    error("错误: 未找到匹配 '%s' 的网格文件。", grid_file_pattern);
end
% 使用最新的网格文件
[~, idx] = sort([grid_files.datenum], 'descend');
latest_grid_file = grid_files(idx(1)).name;
fprintf("正在使用网格文件: %s\n", latest_grid_file);

try
    grid_table = readtable(latest_grid_file, 'VariableNamingRule', 'preserve');
catch ME
    error("无法读取网格文件 '%s': %s", latest_grid_file, ME.message);
end

% 初始化相交计数和尖灭点计数
grid_table.polygon_intersection_count = zeros(height(grid_table), 1);
grid_table.tip_point_count = zeros(height(grid_table), 1); % 新增尖灭点计数

% 获取断层文件列表
fault_files = dir(fullfile(fault_data_dir, '*.csv'));
if isempty(fault_files)
    warning("在目录 '%s' 中未找到断层文件。", fault_data_dir);
    % 如果没有断层文件，直接输出结果并返回
    writetable(grid_table, output_file, 'WriteRowNames', false, 'Encoding', 'UTF-8');
    fprintf("处理完成，结果已保存到 '%s'。\n", output_file);
    return;
end

% --- 2. 遍历所有断层文件，计算尖灭点 ---
fprintf('开始计算断层尖灭点...\n');
for j = 1:length(fault_files)
    fault_file = fullfile(fault_data_dir, fault_files(j).name);
    
    try
        fault_table = readtable(fault_file, 'VariableNamingRule', 'preserve');
    catch ME
        fprintf("读取断层文件 '%s' 时出错: %s\n", fault_files(j).name, ME.message);
        continue;
    end
    
    if ~ismember('X', fault_table.Properties.VariableNames) || ~ismember('Y', fault_table.Properties.VariableNames)
        fprintf("断层文件 '%s' 缺少 'X' 或 'Y' 列。\n", fault_files(j).name);
        continue;
    end
    
    points = [fault_table.X, fault_table.Y];
    num_points = size(points, 1);
    
    % 一个断层至少需要3个点才能形成一个角
    if num_points < 3
        continue;
    end
    
    % 遍历断层上的点，检查锐角
    for k = 2:(num_points - 1)
        p1 = points(k-1, :);
        p2 = points(k, :); % 角点
        p3 = points(k+1, :);
        
        % 计算向量
        v1 = p1 - p2;
        v2 = p3 - p2;
        
        % 计算点积
        dot_product = dot(v1, v2);
        
        % 计算向量长度
        norm_v1 = norm(v1);
        norm_v2 = norm(v2);
        
        % 检查是否为锐角 (点积 > 0)
        if dot_product > 0
            % 找到角点 p2 所在的网格
            for i = 1:height(grid_table)
                grid_row = grid_table(i, :);
                grid_x_min = grid_row.('Geo X Min (m)');
                grid_x_max = grid_row.('Geo X Max (m)');
                grid_y_min = grid_row.('Geo Y Min (m)');
                grid_y_max = grid_row.('Geo Y Max (m)');
                
                if p2(1) >= grid_x_min && p2(1) < grid_x_max && p2(2) >= grid_y_min && p2(2) < grid_y_max
                    grid_table.tip_point_count(i) = grid_table.tip_point_count(i) + 1;
                    break; % 点只可能在一个网格中，找到后跳出循环
                end
            end
        end
    end
end
fprintf('断层尖灭点计算完成。\n');

% --- 3. 遍历每个网格单元，计算断层相交 ---
fprintf('开始计算断层与网格相交...\n');
for i = 1:height(grid_table)
    grid_row = grid_table(i, :);
    grid_x_min = grid_row.('Geo X Min (m)');
    grid_x_max = grid_row.('Geo X Max (m)');
    grid_y_min = grid_row.('Geo Y Min (m)');
    grid_y_max = grid_row.('Geo Y Max (m)');
    
    polygons_counted = 0;
    
    % 遍历每个断层文件 (多边形)
    for j = 1:length(fault_files)
        fault_file = fullfile(fault_data_dir, fault_files(j).name);
        
        try
            fault_table = readtable(fault_file, 'VariableNamingRule', 'preserve');
        catch ME
            % 错误信息在尖灭点计算时已经打印，这里不再重复
            continue;
        end
        
        if ~ismember('X', fault_table.Properties.VariableNames) || ~ismember('Y', fault_table.Properties.VariableNames)
            continue;
        end
        
        points = [fault_table.X, fault_table.Y];
        num_points = size(points, 1);
        
        if num_points < 2
            continue;
        end
        
        % 检查当前多边形是否有任何边与网格相交
        fault_intersects = false;
        for k = 1:num_points - 1 % 只检查断层线段，不闭合
            p1 = points(k, :);
            p2 = points(k + 1, :);
            
            bbox = [grid_x_min, grid_y_min, grid_x_max, grid_y_max];
            if line_intersects_grid(p1, p2, bbox) > 0
                fault_intersects = true;
                break; % 找到相交边，无需再检查此断层的其他边
            end
        end
        
        if fault_intersects
            polygons_counted = polygons_counted + 1;
        end
    end
    
    % 更新当前网格的多边形相交计数
    grid_table.polygon_intersection_count(i) = polygons_counted;
end
fprintf('断层与网格相交计算完成。\n');

% --- 4. 输出结果 ---
writetable(grid_table, output_file, 'WriteRowNames', false, 'Encoding', 'UTF-8');
fprintf("处理完成，结果已保存到 '%s'。\n", output_file);
