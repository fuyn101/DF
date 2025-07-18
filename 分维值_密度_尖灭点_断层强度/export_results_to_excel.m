function export_results_to_excel(valid_fractal_info, grid_info, bw_img, scales, valid_count)
% export_results_to_excel: 将分形维数计算结果导出到 Excel 文件
% 输入:
%   valid_fractal_info: 包含有效网格计算结果的结构体
%   grid_info: 包含所有网格信息的结构体数组
%   bw_img: 二值化图像
%   scales: 使用的尺度
%   valid_count: 有效网格的数量

if isempty(valid_fractal_info.index)
    fprintf('\n⚠️ 无有效网格数据可导出\n');
    return;
end

% 创建导出时间戳 (已根据建议修复)
export_time = datestr(datetime("now"), 'yyyymmdd_HHMMSS');
excel_filename = sprintf('fractal_results_%s.xlsx', export_time);

% 创建数据表格
data_table = table();

% 添加基本网格信息
data_table.GridIndex = valid_fractal_info.index';
data_table.GridRow = valid_fractal_info.row_coords';

% 添加地理坐标信息
geo_coords_mat = cell2mat(valid_fractal_info.geo_coords');
data_table.MinX_m = geo_coords_mat(:, 1);
data_table.MaxX_m = geo_coords_mat(:, 2);
data_table.MinY_m = geo_coords_mat(:, 3);
data_table.MaxY_m = geo_coords_mat(:, 4);

% 添加中心坐标
center_coords_mat = cell2mat(valid_fractal_info.center_coords');
data_table.CenterX_m = center_coords_mat(:, 1);
data_table.CenterY_m = center_coords_mat(:, 2);

% 添加分形计算结果
data_table.FractalDimension = valid_fractal_info.final_values';
data_table.R_squared = cell2mat(valid_fractal_info.R_squared_values)';

% 添加断层区域占比
fault_ratios = zeros(valid_count, 1);
for i = 1:valid_count
    idx = valid_fractal_info.row_coords(i);
    y_range = grid_info(idx).pixel_range(1:2);
    x_range = grid_info(idx).pixel_range(3:4);
    sub_img = bw_img(y_range(1):y_range(2), x_range(1):x_range(2));
    fault_ratios(i) = sum(sub_img(:) == 0) / numel(sub_img);
end
data_table.FaultRatio = fault_ratios;

% 添加各尺度盒子数
scales_str = {'Scale1', 'Scale0_5', 'Scale0_25', 'Scale0_125'};

% 确保box_counts_mat是valid_count行×4列的矩阵
if isempty(valid_fractal_info.box_counts)
    box_counts_mat = zeros(valid_count, length(scales));
else
    % 转换前确保所有元素都是列向量
    box_counts_cell = valid_fractal_info.box_counts;
    for i = 1:length(box_counts_cell)
        if iscolumn(box_counts_cell{i})
            box_counts_cell{i} = box_counts_cell{i}';
        end
    end
    box_counts_mat = cell2mat(box_counts_cell');
end

% 检查维度
if size(box_counts_mat, 1) ~= valid_count
    if size(box_counts_mat, 2) == valid_count
        box_counts_mat = box_counts_mat'; % 转置
    else
        error('盒子数矩阵维度不匹配: [%d, %d] vs 有效网格数 %d', ...
            size(box_counts_mat, 1), size(box_counts_mat, 2), valid_count);
    end
end
for i = 1:length(scales)
    col_name = scales_str{i};
    data_table.(col_name) = box_counts_mat(:, i);
end

% --- 将结果写入带有中文标题的 Excel 文件 ---
try
    % 定义中文标题
    descriptions = {
        'Grid Index', 'Grid Row Number', 'Geo X Min (m)', 'Geo X Max (m)', ...
        'Geo Y Min (m)', 'Geo Y Max (m)', 'Center X (m)', 'Center Y (m)', ...
        'Fractal Dimension', 'R-squared', 'Fault Area Ratio', ...
        'Box Count Scale 1', 'Box Count Scale 0.5', 'Box Count Scale 0.25', 'Box Count Scale 0.125'
        };
    
    % 直接将中文标题设置为表的变量名
    data_table.Properties.VariableNames = descriptions;
    
    % 将带有中文标题的表直接写入 Excel 文件
    writetable(data_table, excel_filename, 'WriteVariableNames', true);
    
    fprintf('\n✅ 分形维数结果已导出到 Excel 文件: %s (带中文标题)\n', excel_filename);
    
catch ME
    % 如果上述方法失败，回退到不带中文标题的简单方法
    warning('FWZ:ExcelExportFailed', '创建带中文标题的Excel文件失败: %s. 正在尝试不带标题的导出。', ME.message);
    
    % 恢复原始变量名以进行回退导出
    data_table.Properties.VariableNames = {'GridIndex', 'GridRow', 'MinX_m', 'MaxX_m', 'MinY_m', 'MaxY_m', ...
        'CenterX_m', 'CenterY_m', 'FractalDimension', 'R_squared', 'FaultRatio', ...
        'Scale1', 'Scale0_5', 'Scale0_25', 'Scale0_125'};
    
    writetable(data_table, excel_filename);
    fprintf('\n✅ 分形维数结果已导出到 Excel 文件: %s (无中文标题)\n', excel_filename);
end

fprintf('包含 %d 个有效网格的数据\n', valid_count);
end
