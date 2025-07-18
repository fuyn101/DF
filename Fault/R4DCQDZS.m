% -------------------------------------------------------------------------
% R4DCQDZS.m
% -------------------------------------------------------------------------
% 功能：
%   该脚本用于计算每个网格的断层强度指数。
%   它通过遍历所有断层，计算每个断层对每个网格的强度贡献，
%   然后将这些贡献值累加到相应的网格上，得到每个网格的总断层强度指数。
%
% 计算逻辑：
%   1. 加载断层汇总数据（包含总面积 s 和总周长 C）和网格数据。
%   2. 遍历每个断层：
%      a. 读取该断层的坐标数据，构建多边形。
%      b. 遍历所有网格区块：
%         i.  计算断层与当前网格的交集区域。
%         ii. 如果存在交集，根据公式计算该断层对当前网格强度指数的贡献值。
%             贡献值 = (断层在网格内的面积 / 断层总面积) * (断层总周长 / 2)
%         iii.将贡献值累加到当前网格的总强度指数上。
%   3. 将带有断层强度指数的新列的网格数据保存到 CSV 文件中。
%
% 输入文件：
%   - '断层信息.csv': 断层汇总数据，包含 'N' (名称), 'S' (面积), 'C' (周长)。
%   - '分维值_密度_尖灭点.csv': 网格数据，包含每个网格的地理边界坐标。
%   - '新的断层数据/' 目录下的各个断层坐标文件 (e.g., 'DF1.csv')。
%
% 输出文件：
%   - '分维值_密度_尖灭点_断层强度.csv': 计算结果，在输入网格数据的基础上增加了 'FaultStrengthIndex' 列。
%
% 作者： Cline
% 日期： 2025-07-16
% 版本： 1.1
% -------------------------------------------------------------------------

% R4DCQDZS - 计算每个网格的断层强度指数
%
% 该脚本结合断层几何数据和网格数据，计算每个网格的断层强度指数。
% 计算逻辑：遍历所有断层，计算其对每个网格的贡献值，然后累加。
% 单个断层的贡献值 = (断层在网格内的面积 / 断层总面积) * (断层总周长 / 2)

clear;
clc;
close all;

% 关闭 polyshape 因修复输入数据而产生的警告
warning('off', 'MATLAB:polyshape:repairedBySimplify');

% --- 1. 配置输入和输出 ---
disp('正在配置参数...');

% 输入文件和目录
fault_summary_file = '断层信息.csv';
grid_data_file     = '分维值_密度_尖灭点.csv';
fault_data_dir     = '新的断层数据';

% 输出文件
output_filename = '分维值_密度_尖灭点_断层强度.csv';

disp('配置完成。');

% --- 2. 加载数据 ---
disp('正在加载数据...');

% 设置文件读取选项，指定编码为 UTF-8
opts = detectImportOptions(fault_summary_file, 'Encoding', 'UTF-8');
opts = setvartype(opts, 'N', 'string'); % 将N读取为字符串
fault_summary = readtable(fault_summary_file, opts);

grid_data = readtable(grid_data_file);

% --- 3. 初始化结果存储 ---
% 为每个网格初始化一个强度指数
num_grids = height(grid_data);
grid_strength_index = zeros(num_grids, 1);

disp('数据加载完成，开始计算...');

% --- 4. 遍历每个断层，计算其对每个网格的贡献 ---
num_faults = height(fault_summary);
for i = 1:num_faults
    % 获取当前断层的信息
    fault_name = fault_summary.N(i);
    total_area = fault_summary.S(i);
    perimeter = fault_summary.C(i); % 对于面状断层是周长，对于线状断层是长度
    
    fprintf('正在处理断层: %s (%d/%d)\n', fault_name, i, num_faults);
    
    % 构建断层坐标文件的路径
    fault_file_path = fullfile(fault_data_dir, [char(fault_name), '.csv']);
    
    % 检查文件是否存在
    if ~isfile(fault_file_path)
        warning('未找到断层文件: %s，跳过此断层。', fault_file_path);
        continue;
    end
    
    % 读取断层坐标并创建多边形
    % MATLAB 会自动处理重复顶点等问题，并给出警告。该警告已在脚本开头关闭。
    fault_coords = readmatrix(fault_file_path);
    fault_poly = polyshape(fault_coords(:, 1), fault_coords(:, 2));
    
    % 遍历所有网格区块
    for j = 1:num_grids
        % 获取网格区块的边界
        x_min = grid_data.GeoXMin_m_(j);
        x_max = grid_data.GeoXMax_m_(j);
        y_min = grid_data.GeoYMin_m_(j);
        y_max = grid_data.GeoYMax_m_(j);
        
        % 创建网格区块的多边形
        grid_poly = polyshape([x_min, x_max, x_max, x_min], [y_min, y_min, y_max, y_max]);
        
        % 计算断层与网格的交集
        intersection_poly = intersect(fault_poly, grid_poly);
        
        % 如果有交集，计算贡献值
        if intersection_poly.NumRegions > 0
            contribution = 0;
            % 判断是面状断层还是线状断层
            if total_area > 0
                % --- 面状断层 ---
                area_in_grid = area(intersection_poly);
                % 应用公式: (网格内面积 / 总面积) * (总周长 / 2)
                contribution = (area_in_grid / total_area) * (perimeter / 2)/10000000;
            else
                % --- 线状断层 (总面积为0) ---
                total_length = perimeter;
                if total_length > 0
                    % 交集多边形的周长的一半是线段在网格内的长度
                    length_in_grid = perimeter(intersection_poly) / 2/10000000;
                    % 应用公式: (网格内长度 / 总长度) * (总周长 / 2)
                    % 简化后为: length_in_grid / 2
                    contribution = length_in_grid / 2;
                end
            end
            
            % 累加到网格的强度指数
            grid_strength_index(j) = grid_strength_index(j) + contribution;
        end
    end
end

% --- 5. 将计算结果添加到网格数据中并保存 ---
% 将新的强度指数列添加到 grid_data 表中
grid_data.FaultStrengthIndex = grid_strength_index;

% 保存更新后的表格到 CSV 文件
writetable(grid_data, output_filename, 'Encoding', 'UTF-8');
