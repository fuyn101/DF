% �ú���������ֱ�Ϊ���ݾ��󣬷���ֵΪ�����ص�Ȩ��

% �������ݾ��������������
[row, col] = size(S1);

% ����������ݵ���ֵ
p = S1./repmat(sum(S1), row, 1);
logp = log2(p);

entropy = -sum(p.*logp)/log2(row);

% ������Ϣ��
e = sum(1-entropy);

% ����Ȩ��
weights = (1-entropy)./e;