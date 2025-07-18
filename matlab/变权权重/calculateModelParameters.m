function model_params = calculateModelParameters(w0, w, x, d, calib_indices)
% calculateModelParameters - 根据标定数据计算状态变权模型的关键参数
%
% 输入:
%   w0: 常数权重向量 (1 x n)
%   w:  理想权重向量 (1 x n)
%   x:  标定样本向量 (1 x n)
%   d:  变权区间矩阵 (n x 3)
%   calib_indices: 包含标定指标索引的结构体
%
% 输出:
%   model_params: 包含c, a1, a2, a3的结构体，如果失败则为空

    model_params = []; % 初始化输出

    % 从结构体中提取索引，提高代码可读性
    p_idx = calib_indices.punish;
    n_idx = calib_indices.neutral;
    i_idx = calib_indices.incentive;
    si_idx = calib_indices.strong_incentive;

    % 为保证方程有稳定的解，原作者建议k3=2。我们采纳这个建议以简化模型。
    % 原始的k3计算式可能存在笔误或针对特定问题，设为常数更具通用性。
    % k3_original = (d(5,1)-x(5))/(d(1,1)-x(1)); % 原代码，可能存在索引越界和笔误
    k3 = 2; 

    % 计算方程系数k1, k2 (公式源自原代码)
    a = length(w0);
    all_indices = 1:a;
    calib_set = [p_idx, n_idx, i_idx, si_idx]; % 参与标定的指标集合
    other_indices = setdiff(all_indices, calib_set);

    % Note: The k1 formula is complex and derived from a specific state-balance equation.
    % We assume the logic 'sum(w(1:4))' from original code refers to the sum of ideal
    % weights of the 4 calibration indicators, and 'sum(w0(5:a))' refers to the
    % sum of constant weights of all *other* indicators.
    k1 = (w0(n_idx) - w0(n_idx)*sum(w(calib_set)) - w(n_idx)*sum(w0(other_indices))) / (w(n_idx)*w0(p_idx));
    k2 = (w(p_idx)*w0(n_idx) - w(n_idx)*w0(p_idx)) / (w(n_idx)*w0(p_idx));
    
    % 使用符号工具箱解方程
    syms c_sym
    eqn = k1 * c_sym == (k2 * c_sym + 1)^k3 - 1;
    
    try
        % vpasolve用于数值求解
        c_val = vpasolve(eqn, c_sym);
        % 如果有多个解，通常取第一个正实数解
        c_val = double(c_val);
        c_val = c_val(c_val > 0 & imag(c_val)==0);
        if isempty(c_val)
            error('方程eqn1没有找到正实数解 for c.');
        end
        c = c_val(1);
    catch ME
        fprintf('错误: 无法求解参数c。\n');
        fprintf('原因: %s\n', ME.message);
        fprintf('请检查您的标定参数(w0, w, x, d)是否合理。\n');
        return;
    end
    
    % 根据求解出的c，计算a1, a2, a3
    a1 = (1/(d(p_idx,1) - x(p_idx))) * log( ((w(p_idx)*w0(n_idx) - w(n_idx)*w0(p_idx)) / (w(n_idx)*w0(p_idx)))*c + 1);
    a2 = (1/(x(i_idx) - d(i_idx,2))) * log( ((w(i_idx)*w0(n_idx) - w(n_idx)*w0(i_idx)) / (w(n_idx)*w0(i_idx)))*c + 1);
    a3 = (1/(x(si_idx) - d(si_idx,3))) * log( ((w(si_idx)*w0(n_idx) - w(n_idx)*w0(si_idx)) / (w(n_idx)*w0(si_idx)))*c + 2 ...
        - ( ((w(i_idx)*w0(n_idx) - w(n_idx)*w0(i_idx)) / (w(n_idx)*w0(i_idx)))*c + 1 )^((d(si_idx,3) - d(si_idx,2))/(x(i_idx) - d(i_idx,2))) );
    
    % 将结果存入结构体
    model_params.c = c;
    model_params.a1 = real(a1); % 取实部以防计算中出现微小的虚部
    model_params.a2 = real(a2);
    model_params.a3 = real(a3);
end
