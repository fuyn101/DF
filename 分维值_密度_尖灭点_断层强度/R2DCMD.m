% R2DCMD - 计算每个网格与多少个断层线（多边形）相交
%
% 功能:
%   该脚本读取一个定义了地理网格的CSV文件和一系列表示断层线的CSV文件。
%   对于每个网格单元，它会计算有多少个断层线（表示为闭合多边形）
%   的边界与之相交。最终结果会保存到一个新的CSV文件中。
%
% 输入:
%   1. 网格文件 (CSV):
%      - 由 'grid_file_pattern' 变量指定 (默认为 '分维值结果.csv')。
%      - 必须包含以下列:
%        - 'Geo X Min (m)': 网格单元的最小X坐标。
%        - 'Geo X Max (m)': 网格单元的最大X坐标。
%        - 'Geo Y Min (m)': 网格单元的最小Y坐标。
%        - 'Geo Y Max (m)': 网格单元的最大Y坐标。
%
%   2. 断层数据 (文件夹):
%      - 由 'fault_data_dir' 变量指定 (默认为 '平禹断层数据')。
%      - 文件夹内包含多个CSV文件，每个文件代表一个断层（多边形）。
%      - 每个断层CSV文件必须包含 'X' 和 'Y' 列，表示多边形顶点的坐标。
%
% 输出:
%   - 结果文件 (CSV):
%     - 文件名由 'output_file' 变量指定 (默认为 'grid_polygon_intersection_counts.csv')。
%     - 该文件是输入网格文件的副本，并增加了一列:
%       - 'polygon_intersection_count': 记录与该网格单元相交的断层多边形数量。
%
% 依赖项:
%   - line_intersects_grid.m: 一个辅助函数，用于判断线段是否与矩形网格相交。
%
% 使用方法:
%   1. 确保输入文件和文件夹已按要求准备好。
%   2. 在MATLAB中运行此脚本。
%   3. 检查输出文件以获取结果。

% 主函数，用于计算每个网格与多少个断层线相交

% --- 配置 ---
grid_file_pattern = '分维值结果.csv'; % 网格文件模式
fault_data_dir = '新的断层数据'; % 断层数据目录
output_file = '分维值_密度.csv'; % 输出文件
addpath('Fault/R2'); % 添加R1文件夹到MATLAB路径
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

% 初始化相交计数
grid_table.polygon_intersection_count = zeros(height(grid_table), 1);

% 获取断层文件列表
fault_files = dir(fullfile(fault_data_dir, '*.csv'));
if isempty(fault_files)
    warning("在目录 '%s' 中未找到断层文件。", fault_data_dir);
    % 如果没有断层文件，直接输出结果并返回
    writetable(grid_table, output_file, 'WriteRowNames', false, 'Encoding', 'UTF-8');
    fprintf("处理完成，结果已保存到 '%s'。\n", output_file);
    return;
end

% --- 2. 遍历每个网格单元 ---
for i = 1:height(grid_table)
    grid_row = grid_table(i, :);
    grid_x_min = grid_row.('Geo X Min (m)');
    grid_x_max = grid_row.('Geo X Max (m)');
    grid_y_min = grid_row.('Geo Y Min (m)');
    grid_y_max = grid_row.('Geo Y Max (m)');
    
    
    polygons_counted = 0;
    
    % --- 3. 遍历每个断层文件 (多边形) ---
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
        
        if num_points < 2
            continue;
        end
        
        % --- 4. 检查当前多边形是否有任何边与网格相交 ---
        fault_intersects = false;
        for k = 1:num_points
            p1 = points(k, :);
            p2 = points(mod(k, num_points) + 1, :); % 闭合曲线
            
            % 调用辅助函数判断线段是否与网格相交
            if line_intersects_grid(p1, p2, [grid_x_min, grid_y_min, grid_x_max, grid_y_max]) > 0
                fault_intersects = true;
                break; % 找到相交边，无需再检查此多边形的其他边
            end
        end
        
        if fault_intersects
            polygons_counted = polygons_counted + 1;
        end
    end
    
    % --- 5. 更新当前网格的多边形相交计数 ---
    grid_table.polygon_intersection_count(i) = polygons_counted;
end

% --- 6. 输出结果 ---
writetable(grid_table, output_file, 'WriteRowNames', false, 'Encoding', 'UTF-8');
fprintf("处理完成，结果已保存到 '%s'。\n", output_file);
