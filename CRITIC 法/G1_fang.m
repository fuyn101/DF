function w_subjective = G1_fang(m)
% G1_fang.m: 使用序关系分析法(G1法)确定主观权重
% 输入:
%   m - 指标数量
% 输出:
%   w_subjective - 主观权重向量 (1 x m)

disp('===== 4. 序关系分析法(G1法)确定主观权重 =====');

% 让专家对指标重要性排序
disp('请专家对指标按重要性从高到低排序(输入指标编号1~m):');
rankOrder = zeros(1, m);
for i = 1:m
    prompt = sprintf('请输入第%d重要的指标编号(1~%d): ', i, m);
    rankOrder(i) = input(prompt);
    while ~ismember(rankOrder(i), 1:m) || ismember(rankOrder(i), rankOrder(1:i-1))
        disp('输入错误或重复，请重新输入');
        rankOrder(i) = input(prompt);
    end
end

disp('指标重要性排序:');
disp(rankOrder);

% 输入相邻指标重要性比较值r_k
r = zeros(1, m);
for k = 2:m
    prompt = sprintf('请输入r_%d (指标%d相对于指标%d的重要性比值, 建议1.0-1.8): ', k, rankOrder(k-1), rankOrder(k));
    r(k) = input(prompt);
    while r(k) < 1.0 || r(k) > 1.8
        disp('输入超出建议范围(1.0-1.8)，请重新输入');
        r(k) = input(prompt);
    end
end

% 计算主观权重
w_subjective = zeros(1, m);
w_subjective(rankOrder(m)) = 1; % 最不重要指标的权重设为1

for k = m:-1:2
    w_subjective(rankOrder(k-1)) = r(k) * w_subjective(rankOrder(k));
end

w_subjective = w_subjective / sum(w_subjective); % 归一化

disp('主观权重(G1法):');
disp(w_subjective);

end
