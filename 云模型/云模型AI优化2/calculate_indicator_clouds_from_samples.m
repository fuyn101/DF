% calculate_indicator_clouds_from_samples.m
function indicator_clouds = calculate_indicator_clouds_from_samples(data_matrix)
    % 输入:
    %   data_matrix: n x m 矩阵, n=样本数, m=指标数
    % 输出:
    %   indicator_clouds: 1 x m 的结构体数组, 每个元素包含 {Ex, En, He}

    [~, n_indicators] = size(data_matrix);
    indicator_clouds = struct('Ex', cell(1, n_indicators), ...
                              'En', cell(1, n_indicators), ...
                              'He', cell(1, n_indicators));

    for j = 1:n_indicators
        A = data_matrix(:, j); % 获取第j个指标的所有样本数据
        
        % 计算期望 Ex (样本均值)
        Ex = mean(A);
        
        % 计算熵 En (基于一阶绝对中心矩)
        En = mean(abs(A - Ex)) * sqrt(pi/2);
        
        % 计算超熵 He
        % 使用总体方差(分母为n), 即 var(A, 1)
        S2 = var(A, 1);
        
        % 防止浮点数误差导致根号下为负
        He = sqrt(max(0, S2 - En^2));
        
        indicator_clouds(j).Ex = Ex;
        indicator_clouds(j).En = En;
        indicator_clouds(j).He = He;
    end
end
