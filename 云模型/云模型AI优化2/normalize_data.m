% normalize_data.m
function norm_data = normalize_data(data, types)
    [n_samples, n_indicators] = size(data);
    norm_data = zeros(n_samples, n_indicators);

    for i = 1:n_indicators
        col = data(:, i);
        min_val = min(col);
        max_val = max(col);
        range = max_val - min_val;

        if range < 1e-9 % 如果一列中所有值都相同，避免除以零
            norm_data(:, i) = 50; % 给予一个中间值
            continue;
        end
        
        if strcmpi(types{i}, 'positive') % 正向指标
            norm_data(:, i) = (col - min_val) / range * 100;
        elseif strcmpi(types{i}, 'negative') % 负向指标
            norm_data(:, i) = (max_val - col) / range * 100;
        else
            error('指标类型 "%s" 无效，请使用 "positive" 或 "negative"。', types{i});
        end
    end
end
