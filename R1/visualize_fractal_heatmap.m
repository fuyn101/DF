function visualize_fractal_heatmap(img, R, valid_fractal_info, grid_info)
    % visualize_fractal_heatmap: 生成并显示分形维数的热力图
    % 输入:
    %   img: 原始的GeoTIFF图像
    %   R: GeoTIFF图像的地理参考对象
    %   valid_fractal_info: 包含有效网格计算结果的结构体
    %   grid_info: 包含所有网格信息的结构体数组

    % 统计并显示热点图框的数量
    fprintf('热点图框的数量: %d\n', length(valid_fractal_info.index));

    % 创建图形
    figure;
    hold on;

    % 显示原始断层图（最底层，30%透明度）
    h_fault = mapshow(img, R);
    set(h_fault, 'AlphaData', 0.8); % 关键修改：设置透明度

    % 显示分形维数热点图
    for k = 1:length(valid_fractal_info.index)
        idx = valid_fractal_info.index(k);
        coords = grid_info(idx).coords;
        
        fill([coords(1),coords(2),coords(2),coords(1)],...
             [coords(3),coords(3),coords(4),coords(4)],...
             valid_fractal_info.final_values(k),...
             'EdgeColor','none','FaceAlpha',0.6);
        
        text(mean(coords(1:2)), mean(coords(3:4)), ...
             num2str(idx),...
             'HorizontalAlignment','center','FontSize',8,'Clipping','on');
    end
    colormap(jet);
    colorbar;

    % 图形修饰
    title('分维值热点图');
    axis equal tight;
    grid on;
    hold off;
end
