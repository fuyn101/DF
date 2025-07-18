% =====================================================================================
%  - 文件名: FWZ.m
%  - 作者: FANG LI
%  - 创建日期: 2025-7-7
%  - 最后修改日期: 2025-7-14
%
%  - 功能描述:
%    本脚本用于计算和分析断层图像的分形维数。它通过一系列模块化的函数，
%    实现了从图像读取、预处理、网格划分、分形维数计算，到最终结果的可视化
%    和数据导出的完整工作流程。
%
%  - 主要处理步骤:
%    1. 初始化: 清理环境，设置字体，启动日志记录。
%    2. 参数定义: 设置输入图像路径、网格大小、颜色阈值等核心参数。
%    3. 图像读取与预处理: 读取TIF格式的断层图像，并将其转换为二值图像。
%    4. 地理网格创建: 根据图像的地理参考信息和设定的网格尺寸，创建分析网格。
%    5. 分形维数计算: 对每个网格进行计盒法分形维数计算。
%    6. 结果导出: 将计算结果（如分形维数、网格坐标等）保存为CSV文件。
%    7. 结果可视化: 生成分形维数空间分布的热力图。
%
%  - 输入要求:
%    - 图像格式: TIF (geotiff)，背景为白色，断层为红色。
%    - 图像路径: 在 "参数定义" 部分的 `IMAGE_PATH` 变量中指定。
%
%  - 输出结果:
%    1. 分形维数热力图: 直观展示分形维数的空间分布特征。
%    2. CSV结果文件: 包含每个有效网格的详细计算数据，便于后续分析。
%    3. 运行日志: 记录脚本运行过程中的关键信息和时间戳。
%
%  - 依赖函数:
%    - create_grid.m
%    - calculate_fractal_dimension.m
%    - export_results_to_csv.m
%    - visualize_fractal_heatmap.m
%    - visualize_grid.m
%    - box_counting.m
% =====================================================================================

%% 1. 初始化环境
% -------------------------------------------------------------------------------------
clear; clc; close all; % 清理工作区、命令行窗口和关闭所有图形窗口
set(0, 'DefaultAxesFontName', 'Microsoft YaHei'); % 设置默认坐标轴字体
set(0, 'DefaultTextFontName', 'Microsoft YaHei');  % 设置默认文本字体

tic; % 启动总运行时间计时器

% 初始化日志文件c
logFileName = "分维值计算日志.txt";
diary(logFileName);
diary on;

fprintf('============================================================\n');
fprintf('脚本开始运行: %s\n', string(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss')));
fprintf('============================================================\n\n');

%% 2. 参数定义
% -------------------------------------------------------------------------------------
fprintf('--- 正在定义核心参数... ---\n');
IMAGE_PATH = '.\faults_georef.tif';          % 输入图像文件路径
GRID_SIZE_METERS = 800;          % 网格大小（单位：米）
BLANK_THRESHOLD = 250;           % 空白区域的颜色阈值 (R,G,B均大于该值则视为空白)
SCALES = [1, 1/2, 1/4, 1/8];     % 计盒法使用的多尺度比例因子
THRESHOLD_RATIO = 0.0001;         % 网格内断层像素占比阈值 (低于此阈值不计算分维)
fprintf('参数定义完成。\n\n');

%% 3. 读取和预处理图像
% -------------------------------------------------------------------------------------
fprintf('--- 步骤 1: 读取和预处理图像 ---\n');
[img_orig, R_orig] = readgeoraster(IMAGE_PATH); % 读取带地理参考的TIF图像
fprintf('成功读取图像: %s\n', IMAGE_PATH);

% --- 图像尺寸扩展 ---
% 为了确保网格划分的精确性，将图像的地理尺寸扩展到最接近的 GRID_SIZE_METERS 的整数倍。
% 这可以避免在图像边缘出现不完整的网格。

% 1. 获取原始图像的像素尺寸和地理范围
[height_orig_px, width_orig_px, ~] = size(img_orig);
world_width_orig = R_orig.XWorldLimits(2) - R_orig.XWorldLimits(1);
world_height_orig = R_orig.YWorldLimits(2) - R_orig.YWorldLimits(1);
fprintf('原始图像尺寸: %d x %d 像素, 地理范围: %.2f x %.2f 米\n', width_orig_px, height_orig_px, world_width_orig, world_height_orig);

% 2. 计算扩展后的新地理尺寸 (向上取整到网格大小的倍数)
new_world_width = ceil(world_width_orig / GRID_SIZE_METERS) * GRID_SIZE_METERS;
new_world_height = ceil(world_height_orig / GRID_SIZE_METERS) * GRID_SIZE_METERS;

% 3. 根据新的地理尺寸和原始分辨率，计算扩展后的新像素尺寸
pixel_size_x = world_width_orig / width_orig_px;
pixel_size_y = world_height_orig / height_orig_px;
new_width_px = round(new_world_width / pixel_size_x);
new_height_px = round(new_world_height / pixel_size_y);
fprintf('扩展后图像尺寸: %d x %d 像素, 地理范围: %.2f x %.2f 米\n', new_width_px, new_height_px, new_world_width, new_world_height);

% 4. 创建一个新的、更大的白色背景图像
img = ones(new_height_px, new_width_px, size(img_orig, 3), class(img_orig)) * 255;

% 5. 将原始图像内容复制到新图像的左上角
img(1:height_orig_px, 1:width_orig_px, :) = img_orig;
fprintf('图像已扩展，原始图像内容已置于新图像的左上角。\n');

% 6. 更新地理参考对象以匹配新图像的尺寸和范围
R = R_orig;
R.RasterSize = [new_height_px, new_width_px];
R.XWorldLimits = [R_orig.XWorldLimits(1), R_orig.XWorldLimits(1) + new_world_width];
R.YWorldLimits = [R_orig.YWorldLimits(2) - new_world_height, R_orig.YWorldLimits(2)];
fprintf('地理参考信息已更新以匹配扩展后的图像。\n');
% --- 图像扩展结束 ---

% 显示原始断层图像
figure('Name', '原始断层图像');
mapshow(img_orig, R_orig);
title('原始断层图像');

% 显示扩展后的图像
figure('Name', '扩展后的断层图像');
mapshow(img, R);
title('扩展后的断层图像');

% 将图像转换为二值图像 (断层为0, 背景为1)
% 通过检查RGB值是否都大于阈值来识别白色背景
blank_mask = all(img >= BLANK_THRESHOLD, 3);
bw_img = double(blank_mask);

% 显示二值化后的图像
figure('Name', '二值化图像');
imshow(bw_img);
title('断层图像二值化 (断层: 黑色, 背景: 白色)');
fprintf('图像二值化完成。\n\n');

%% 4. 创建地理网格
% -------------------------------------------------------------------------------------
fprintf('--- 步骤 2: 创建地理网格 ---\n');
addpath('R1'); % 添加R1文件夹到MATLAB路径
[grid_info, x_coords, y_coords] = create_grid(R, bw_img, GRID_SIZE_METERS);
fprintf('成功创建 %d 个地理网格。\n', length(grid_info));

% 可视化网格划分结果
visualize_grid(bw_img, R, grid_info, x_coords, y_coords);
fprintf('网格划分可视化完成。\n\n');

%% 5. 计算分形维数
% -------------------------------------------------------------------------------------
fprintf('--- 步骤 3: 计算各网格的分形维数 ---\n');
[valid_fractal_info, valid_count, invalid_count] = ...
    calculate_fractal_dimension(grid_info, bw_img, SCALES, THRESHOLD_RATIO);

% 打印计算结果统计摘要
fprintf('\n======= 分形维数计算统计摘要 =======\n');
fprintf('总网格数: %d\n', length(grid_info));
fprintf('断层占比达标网格数: %d\n', valid_count + invalid_count);
fprintf('  - 其中有效分形维数网格: %d\n', valid_count);
fprintf('  - 其中无效分形维数网格: %d\n', invalid_count);
if (valid_count + invalid_count) > 0
    valid_percentage = 100 * valid_count / (valid_count + invalid_count);
    fprintf('有效网格在达标网格中的占比: %.1f%%\n', valid_percentage);
else
    fprintf('有效网格在达标网格中的占比: 0%%\n');
end
fprintf('======================================\n\n');

%% 6. 导出结果到CSV
% -------------------------------------------------------------------------------------
fprintf('--- 步骤 4: 导出计算结果到 CSV 文件 ---\n');
export_results_to_csv(valid_fractal_info, grid_info, bw_img, SCALES, valid_count);

%% 7. 可视化分形维数热力图
% -------------------------------------------------------------------------------------
fprintf('--- 步骤 5: 可视化分形维数热力图 ---\n');
if valid_count > 0
    visualize_fractal_heatmap(img, R, valid_fractal_info, grid_info);
    fprintf('分形维数热力图生成完毕。\n');
else
    fprintf('没有有效的网格数据，无法生成热力图。\n');
end

%% 脚本结束
% -------------------------------------------------------------------------------------
totalTime = toc; % 停止计时器
fprintf('\n============================================================\n');
fprintf('>>> 脚本运行完成，总耗时 %.2f 秒。\n', totalTime);
fprintf('>>> 日志文件已保存在: \n    %s\n', which(logFileName));
fprintf('============================================================\n');
diary off; % 关闭日志记录
