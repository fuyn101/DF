function [scale_fractals, R_squared_values, final_D, box_counts, log_scales, log_counts] = box_counting(img, scales)
    % box_counting: 根据盒子计数法计算图像的分形维数
    % 输入:
    %   img: 二值化图像 (断层为0, 背景为1)
    %   scales: 用于计算的尺度数组 (例如 [1, 1/2, 1/4, 1/8])
    % 输出:
    %   scale_fractals: 各尺度下的计数值的对数 (兼容旧输出)
    %   R_squared_values: 线性拟合的R²值
    %   final_D: 最终计算出的分形维数
    %   box_counts: 各尺度下原始的盒子计数值
    %   log_scales: log(1/ε) 的值
    %   log_counts: log(N(ε)) 的值

    img = double(img);
    N = size(img, 1);  
    
    box_counts = zeros(length(scales), 1);  % 存储原始盒子数
    log_counts = [];   % 存储 log(N(ε))
    log_scales = [];   % 存储 log(1/ε)
    scale_fractals = []; % 兼容旧输出

    % 遍历所有尺度
    for k = 1:length(scales)
        s = scales(k) * N;  % 当前盒子尺寸（像素）
        num_boxes = ceil(N / s);  % 网格划分数量
        
        count = 0;  % 初始化盒子计数器
        
        % 遍历所有盒子
        for i = 1:num_boxes
            for j = 1:num_boxes
                % 计算当前盒子边界（防止越界）
                row_start = floor((i-1)*s)+1;
                row_end = min(floor(i*s), N);
                col_start = floor((j-1)*s)+1;
                col_end = min(floor(j*s), N);
                
                % 提取子图像
                sub = img(row_start:row_end, col_start:col_end);
                
                % 检测盒子是否包含断层(0值)
                if any(sub(:) == 0)  
                    count = count + 1;  % 包含断层的盒子计数
                end
            end
        end
        
        % 存储当前尺度的盒子数
        box_counts(k) = count;
        
        % 实时输出当前尺度结果
        if count > 0
            log_scale = log(1 / scales(k));
            log_count = log(count);
            fprintf('%.4f\t%.1f\t\t%d\t\t%.4f\t\t%.4f\n', ...
                    scales(k), s, count, log_scale, log_count);
            
            % 存储对数转换值
            log_scales = [log_scales; log_scale];
            log_counts = [log_counts; log_count];
        else
            fprintf('%.4f\t%.1f\t\t%d\t\t%.4f\t\tNaN\n', ...
                    scales(k), s, 0, log(1 / scales(k)));
        end
    end

    % 线性回归计算分形维数（需要至少2个有效点）
    if length(log_scales) >= 2
        p = polyfit(log_scales, log_counts, 1);  % 线性拟合
        final_D = abs(p(1));  % 分形维数=斜率绝对值
        
        % 计算R²值
        y_fit = polyval(p, log_scales);
        ss_total = sum((log_counts - mean(log_counts)).^2);
        ss_residual = sum((log_counts - y_fit).^2);
        R_squared_values = 1 - (ss_residual / ss_total);
    else
        final_D = NaN; % 标记为无效
        R_squared_values = NaN;
    end
    
    % 兼容旧输出
    scale_fractals = log_counts;
end
