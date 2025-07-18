
clear;clc;
data=[126.6	0.19	13.5	59.5	57	3
97.8	4.97	13.8	55	45	1
37.5	0.26	23	57	50	1
61.2	6.47	26	53	47	2
71.7	0.75	39.5	50	53	2
60	0.85	11.2	50	50	2
48.9	1.5	40	51.5	56.5	1
67.2	1.32	28	50	40	1
84	0.85	35	56	70	3
63.6	0.26	42.9	56	32	2
99.9	1.88	20.6	57	80	3
75	1.92	22	60	100	4
66	1.41	41	62	90	3
64.8	0.19	37	55	80	3
93.6	2.11	50	60	50	3];
%获取行数列数
r = size(data,1);
c = size(data,2);
%首先，把我们的原始指标矩阵正向化
%第三列极小型--->极大型
max_value = max(data(:,2)); 
data(:,2) = abs(data(:,2)-max_value);
max_value = max(data(:,3)); 
data(:,3) = abs(data(:,3)-max_value);
max_value = max(data(:,6)); 
data(:,6) = abs(data(:,6)-max_value);
disp("正向化后的矩阵为：");
disp(data);
%把正向化后的矩阵进行预处理，消除量纲的影响
avg = repmat(mean(data),r,1);
new_data = data./avg;
%将预处理后的矩阵每一行的最大值取出，当成母序列(虚构的)
Y = max(new_data,[],2);
%计算各个指标和母序列的灰色关联度
%先把new_data矩阵所有元素都减去母序列中同行的元素，并取绝对值
Y2 = repmat(Y,1,c);
new_data = abs(new_data-Y2);
a = min(min(new_data)); %全矩阵最小值
b = max(max(new_data)); %全矩阵最大值
ro = 0.5;
new_data = (a+ro*b)./(new_data+ro*b);
disp("各个指标对于母序列的灰色关联度为：");
gamma = mean(new_data);
%计算各个指标的权重
disp("各个指标的权重为：");
weight = gamma./(sum(gamma,2));