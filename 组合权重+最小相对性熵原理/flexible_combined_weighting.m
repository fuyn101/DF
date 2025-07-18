function combined_weights = flexible_combined_weighting(varargin)
% 灵活的组合权重计算函数
% 输入:
%   varargin - 一个或多个权重向量 (例如: w1, w2, w3, ...)
%              每个向量都应为 1xN 或 Nx1 的数值数组。
% 输出:
%   combined_weights - 组合权重向量 (与输入向量同尺寸)

% --- 1. 输入验证 ---
num_vectors = nargin; % 获取输入向量的数量

if num_vectors < 2
    error('至少需要两个权重向量作为输入才能进行组合。');
end

% 检查所有向量长度是否一致
first_vec_len = length(varargin{1});
for i = 2:num_vectors
    if length(varargin{i}) ~= first_vec_len
        error('所有输入的权重向量长度必须一致。');
    end
end
num_indicators = first_vec_len;

% --- 2. 核心计算 ---
% 初始化一个与权重向量同尺寸的乘积累加器
product_weights = ones(size(varargin{1}));

% 逐个元素相乘，计算所有权重向量的乘积
for i = 1:num_vectors
    % 确保所有输入都是行向量，以防混合输入
    product_weights = product_weights .* reshape(varargin{i}, 1, num_indicators);
end

% 计算几何平均值 (N个向量相乘，则开N次方)
geo_mean = product_weights .^ (1/num_vectors);

% 归一化得到最终的组合权重
combined_weights = geo_mean / sum(geo_mean);

% --- 3. 结果验证 ---
if abs(sum(combined_weights) - 1) > 1e-6
    warning('最终组合权重的和不为1，请检查输入向量。');
end

% --- 4. 可视化与输出 (仅在没有输出参数接收结果时显示，或总是显示) ---
% 如果您希望仅在调用函数时不接收返回值时才绘图，可以取消下面这行注释
% if nargout == 0 

    % a. 计算所有权重中的最大值，用于统一Y轴
    all_weights_flat = [varargin{:}];
    max_y_val = max([all_weights_flat, combined_weights]) * 1.2;

    % b. 可视化权重比较
    figure;
    num_plots = num_vectors + 1;
    
    % 绘制每个输入权重
    colors = lines(num_vectors); % 获取一组不同的颜色
    for i = 1:num_vectors
        subplot(num_plots, 1, i);
        bar(varargin{i}, 'FaceColor', colors(i,:));
        title(sprintf('输入权重 %d', i));
        ylabel('权重值');
        ylim([0, max_y_val]);
    end
    
    % 绘制组合权重
    subplot(num_plots, 1, num_plots);
    bar(combined_weights, 'g');
    title('组合权重');
    ylabel('权重值');
    xlabel('指标');
    ylim([0, max_y_val]);

    % c. 输出权重对比表
    fprintf('\n================== 权重对比表 ==================\n');
    % 打印表头
    fprintf('指标\t');
    for i = 1:num_vectors
        fprintf('输入 %d\t\t', i);
    end
    fprintf('组合权重\n');
    
    % 打印数据
    for i = 1:num_indicators
        fprintf('%d\t\t', i); % 打印指标序号
        for j = 1:num_vectors
            fprintf('%.4f\t\t', varargin{j}(i)); % 打印每个输入权重
        end
        fprintf('%.4f\n', combined_weights(i)); % 打印组合权重
    end
    fprintf('====================================================\n');

    % d. 计算组合效果指标 (KL散度)
    fprintf('\n================== 组合效果评估 ==================\n');
    total_divergence = 0;
    for i = 1:num_vectors
        % 防止log(0)出现，为0的权重加上一个极小值
        input_weights_safe = varargin{i};
        input_weights_safe(input_weights_safe == 0) = 1e-12;
        
        divergence = sum(combined_weights .* log(combined_weights ./ input_weights_safe));
        fprintf('与输入权重 %d 的KL散度: %.6f\n', i, divergence);
        total_divergence = total_divergence + divergence;
    end
    fprintf('总相对熵 (所有散度之和): %.6f\n', total_divergence);
    fprintf('====================================================\n');
% end % 对应 if nargout == 0

end
