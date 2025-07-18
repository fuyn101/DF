% normalize_data_hybrid.m
function norm_data = normalize_data_hybrid(data, types, thresholds)
% 基于混合模式进行归一化
% 如果thresholds{i}不为空, 则使用绝对阈值; 否则, 使用相对阈值。
% thresholds: 一个cell数组, 例如 {[min1,max1], [], [min3,max3], ...}
%             [] 表示该指标使用相对归一化

    [n_samples, n_indicators] = size(data);
    norm_data = zeros(n_samples, n_indicators);

    for i = 1:n_indicators
        col = data(:, i);
        
        % 检查当前指标是否使用绝对阈值
        if ~isempty(thresholds{i})
            % --- 使用绝对归一化 ---
            worst_val = thresholds{i}(1);
            best_val = thresholds{i}(2);
        else
            % --- 使用相对归一化 ---
            worst_val = min(col);
            best_val = max(col);
        end
        
        range = best_val - worst_val;
        if range < 1e-9 % 避免除以零
            norm_data(:, i) = 50; % 给一个中间值
            continue;
        end

        % 根据指标类型计算分数
        if strcmpi(types{i}, 'positive') % 正向指标
            norm_data(:, i) = (col - worst_val) / range * 100;
        elseif strcmpi(types{i}, 'negative') % 负向指标
            norm_data(:, i) = (best_val - col) / range * 100;
        end
        
        % 限制分数在[0, 100]之间
        norm_data(norm_data(:, i) > 100, i) = 100;
        norm_data(norm_data(:, i) < 0, i) = 0;
    end
end
