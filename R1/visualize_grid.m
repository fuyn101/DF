function visualize_grid(bw_img, R, grid_info, x_coords, y_coords)
    % visualize_grid: 在地图上可视化网格划分和网格编号
    % 输入:
    %   bw_img: 二值化图像
    %   R: GeoTIFF 图像的地理参考对象
    %   grid_info: 包含网格信息的结构体数组
    %   x_coords: 网格的X方向地理坐标边界
    %   y_coords: 网格的Y方向地理坐标边界

    figure;
    mapshow(bw_img, R); 
    hold on;
    title('网格划分');

    % 绘制网格线
    for i = 1:length(y_coords)
        line([R.XWorldLimits(1), R.XWorldLimits(2)], [y_coords(i), y_coords(i)], ...
             'Color', 'g', 'LineWidth', 1);
    end
    for j = 1:length(x_coords)
        line([x_coords(j), x_coords(j)], [R.YWorldLimits(1), R.YWorldLimits(2)], ...
             'Color', 'g', 'LineWidth', 1);
    end

    % 标注网格编号
    for k = 1:length(grid_info)
        x_center = grid_info(k).center(1);
        y_center = grid_info(k).center(2);
        text(x_center, y_center, num2str(grid_info(k).index), 'Color', 'r', ...
            'FontSize', 8, 'HorizontalAlignment', 'center');
    end
    hold off;
end
