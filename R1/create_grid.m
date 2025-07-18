function [grid_info, x_coords, y_coords] = create_grid(R, bw_img, grid_size_meters)
    % create_grid: 根据地理坐标系统和指定的网格大小划分网格
    % 输入:
    %   R: GeoTIFF 图像的地理参考对象
    %   bw_img: 二值化图像，用于获取图像尺寸
    %   grid_size_meters: 每个网格的边长（米）
    % 输出:
    %   grid_info: 包含每个网格详细信息的结构体数组
    %   x_coords: 网格的X方向地理坐标边界
    %   y_coords: 网格的Y方向地理坐标边界

    % 获取像素的地理尺寸
    pixel_width = R.CellExtentInWorldX;  % 单个像素的宽度（米）
    pixel_height = R.CellExtentInWorldY; % 单个像素的高度（米）

    % 计算每个网格对应的像素数（四舍五入）
    grid_size_x_pixels = round(grid_size_meters / pixel_width);
    grid_size_y_pixels = round(grid_size_meters / pixel_height);

    % 生成地理坐标的网格边界
    x_coords = R.XWorldLimits(1):grid_size_meters:R.XWorldLimits(2); % X从左到右
    y_coords = R.YWorldLimits(1):grid_size_meters:R.YWorldLimits(2); % Y从下到上（地理坐标系）
    num_x = length(x_coords) - 1; % X方向网格数
    num_y = length(y_coords) - 1; % Y方向网格数

    % 创建结构体变量存储网格信息
    grid_info = struct();
    grid_index = 1;

    % 获取图像总高度
    image_height = size(bw_img, 1);

    for i = 1:num_y
        for j = 1:num_x
            % ===== 地理坐标范围 =====
            geo_x_min = x_coords(j);
            geo_x_max = x_coords(j+1);
            geo_y_min = y_coords(i);
            geo_y_max = y_coords(i+1);
            
            % ===== 计算像素范围（注意Y方向转换） =====
            % X方向（与地理坐标一致）
            x_pixel_start = round((geo_x_min - R.XWorldLimits(1)) / pixel_width) + 1;
            x_pixel_end = min(x_pixel_start + grid_size_x_pixels - 1, size(bw_img, 2));
            
            % Y方向（地理坐标→像素坐标需反转）
            y_geo_bottom = geo_y_min; % 地理坐标系下网格底部
            y_pixel_top = image_height - round((y_geo_bottom - R.YWorldLimits(1)) / pixel_height);
            y_pixel_bottom = max(1, y_pixel_top - grid_size_y_pixels + 1);
            
            % ===== 存储网格信息 =====
            grid_info(grid_index).index = grid_index;
            grid_info(grid_index).coords = [geo_x_min, geo_x_max, geo_y_min, geo_y_max]; % 地理坐标范围
            grid_info(grid_index).center = [(geo_x_min+geo_x_max)/2, (geo_y_min+geo_y_max)/2]; % 地理中心
            grid_info(grid_index).pixel_range = [y_pixel_bottom, y_pixel_top, x_pixel_start, x_pixel_end]; % 像素范围
            
            grid_index = grid_index + 1;
        end
    end
end
