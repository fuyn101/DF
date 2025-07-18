function w_subjective = G1(rankOrder, r_values)
% G1.m: 使用序关系分析法(G1法)确定主观权重 (函数式版本)
%
% 本函数根据预先确定的指标重要性排序和相邻指标的重要性比值,
% 计算各指标的主观权重。这种方法避免了交互式输入,适用于自动化
% 和批量计算场景。
%
% 输入:
%   rankOrder - 1xm 的向量, 包含按重要性从高到低排序的指标编号。
%               例如, [3, 1, 2] 表示指标3最重要,其次是1,最后是2。
%   r_values  - 1x(m-1) 的向量, 包含相邻指标的重要性比值 [r_2, r_3, ..., r_m]。
%               其中 r_k = w_{k-1} / w_k, 表示第 k-1 重要的指标
%               (即 rankOrder(k-1)) 与第 k 重要的指标 (即 rankOrder(k))
%               之间的重要性比值。建议值在 1.0 到 1.8 之间。
%
% 输出:
%   w_subjective - 1xm 的向量, 返回计算出的各指标的主观权重,
%                  并且已经归一化,总和为1。
%
% 示例:
%   rankOrder = [3, 1, 4, 2]; % 假设有4个指标, 重要性排序为 3 > 1 > 4 > 2
%   r_values = [1.2, 1.1, 1.3]; % r2, r3, r4 的值
%   weights = G1(rankOrder, r_values);
%   disp('计算出的权重:');
%   disp(weights);

m = length(rankOrder);
if nargin ~= 2
    error('需要提供两个输入参数: rankOrder 和 r_values。');
end

if length(r_values) ~= m - 1
    error('r_values 的长度必须是 rankOrder 的长度减一。');
end

if any(r_values < 1.0)
    warning('部分r_values小于1.0, 这表示后一个指标比前一个更重要, 与排序矛盾。');
end

% 为了与原始算法的r_k索引(从2开始)保持一致,构造一个完整的r向量
r = [NaN, r_values]; % r(1)不使用, r(k)对应第k个比值r_k

% 初始化权重向量
w_subjective = zeros(1, m);

% 计算未归一化的权重
% 1. 将最不重要的指标(排序最后的那个)的权重设为1.0
w_subjective(rankOrder(m)) = 1.0;

% 2. 从后向前递推计算其他指标的权重
%    w_{k-1} = r_k * w_k
for k = m:-1:2
    w_subjective(rankOrder(k-1)) = r(k) * w_subjective(rankOrder(k));
end

% 归一化权重,使其总和为1
w_subjective = w_subjective / sum(w_subjective);

end
