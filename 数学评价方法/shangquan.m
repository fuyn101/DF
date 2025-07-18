% 该函数的输入分别为数据矩阵，返回值为各因素的权重

% 计算数据矩阵的行数和列数
[row, col] = size(S1);

% 计算各列数据的熵值
p = S1./repmat(sum(S1), row, 1);
logp = log2(p);

entropy = -sum(p.*logp)/log2(row);

% 计算信息熵
e = sum(1-entropy);

% 计算权重
weights = (1-entropy)./e;