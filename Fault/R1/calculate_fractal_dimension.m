function [valid_fractal_info, valid_count, invalid_count] = calculate_fractal_dimension(grid_info, bw_img, scales, threshold_ratio)
    % calculate_fractal_dimension: 遍历所有网格，计算分形维数
    % 输入:
    %   grid_info: 包含网格信息的结构体数组
    %   bw_img: 二值化图像
    %   scales: 用于分形维数计算的尺度
    %   threshold_ratio: 判断网格是否有效的断层区域占比阈值
    % 输出:
    %   valid_fractal_info: 包含所有有效网格计算结果的结构体
    %   valid_count: 有效网格的数量
    %   invalid_count: 无效网格的数量

    % 扩展数据结构以存储原始盒子数
    valid_fractal_info = struct();
    valid_fractal_info.index = [];              % 有效网格的编号
    valid_fractal_info.geo_coords = {};         % 有效网格的地理坐标
    valid_fractal_info.center_coords = {};      % 有效网格的中心坐标
    valid_fractal_info.row_coords = [];         % 有效网格的行号
    valid_fractal_info.scale_values = {};       % 对应的尺度值
    valid_fractal_info.box_counts = {};         % 各尺度下的原始盒子数
    valid_fractal_info.log_scales = {};         % log(1/ε) 值
    valid_fractal_info.log_counts = {};         % log(N(ε)) 值
    valid_fractal_info.R_squared_values = {};   % 对应的 R^2 值
    valid_fractal_info.fractal_values = [];     % 分形维数值
    valid_fractal_info.final_values = [];       % 最终的分形维数值

    % 计数器初始化
    valid_count = 0;
    invalid_count = 0;

    % 遍历第3步的所有网格
    for k = 1:length(grid_info)
        % 获取当前网格的像素范围
        y_start = grid_info(k).pixel_range(1);
        y_end = grid_info(k).pixel_range(2);
        x_start = grid_info(k).pixel_range(3);
        x_end = grid_info(k).pixel_range(4);
        
        % 提取当前网格的子图像
        sub_img = bw_img(y_start:y_end, x_start:x_end);
        
        % 计算该网格中断层区域的占比
        fault_ratio = sum(sub_img(:) == 0) / numel(sub_img);
        
        % 仅处理断层区域占比大于阈值的网格
        if fault_ratio >= threshold_ratio
            % ========== 详细输出计算过程 ==========
            fprintf('\n============ 网格 %d 分形维数计算 ============\n', grid_info(k).index);
            fprintf('地理坐标: X[%.1f, %.1f]m, Y[%.1f, %.1f]m\n', ...
                    grid_info(k).coords(1), grid_info(k).coords(2), ...
                    grid_info(k).coords(3), grid_info(k).coords(4));
            fprintf('图像尺寸: %d×%d 像素\n', size(sub_img,2), size(sub_img,1));
            fprintf('断层区域占比: %.4f\n', fault_ratio);
            fprintf('------------------------------------------------\n');
            fprintf('尺度(ε)\t盒子大小(px)\t盒子数(N)\t\tlog(1/ε)\tlog(N(ε))\n');
            fprintf('------------------------------------------------\n');
            
            % 调用分形维数计算函数
            [scale_fractals, R_squared_values, final_D, box_counts, log_scales, log_counts] = ...
                box_counting(sub_img, scales);
            
            % ========== 检查分形维数有效性 ==========
            if isnan(final_D) || final_D <= 0
                fprintf('------------------------------------------------\n');
                fprintf('⚠️ 无效分形维数: D = %.4f (可能原因: 断层线过细或断层线太小)\n', final_D);
                fprintf('❌ 网格 %d 被排除在有效网格之外\n', grid_info(k).index);
                fprintf('================================================\n\n');
                
                % 更新无效计数器
                invalid_count = invalid_count + 1;
                continue; % 跳过后续存储步骤
            end
            
            % ========== 存储有效网格数据 ==========
            valid_count = valid_count + 1;
            
            % 存储网格信息
            valid_fractal_info.index = [valid_fractal_info.index, grid_info(k).index];
            valid_fractal_info.geo_coords{end+1} = grid_info(k).coords;
            valid_fractal_info.center_coords{end+1} = grid_info(k).center;
            valid_fractal_info.row_coords = [valid_fractal_info.row_coords, k];
            
            % 存储分形数据
            valid_fractal_info.box_counts{end+1} = box_counts;
            valid_fractal_info.log_scales{end+1} = log_scales;
            valid_fractal_info.log_counts{end+1} = log_counts;
            valid_fractal_info.scale_values{end+1} = scale_fractals;
            valid_fractal_info.R_squared_values{end+1} = R_squared_values;
            valid_fractal_info.fractal_values = [valid_fractal_info.fractal_values, final_D];
            valid_fractal_info.final_values = [valid_fractal_info.final_values, final_D];
            
            fprintf('------------------------------------------------\n');
            fprintf('✅ 有效结果: 分形维数 D = %.4f, R² = %.4f\n', final_D, R_squared_values);
            fprintf('================================================\n\n');
        end
    end
end
