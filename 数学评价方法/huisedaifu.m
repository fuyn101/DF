
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
%��ȡ��������
r = size(data,1);
c = size(data,2);
%���ȣ������ǵ�ԭʼָ���������
%�����м�С��--->������
max_value = max(data(:,2)); 
data(:,2) = abs(data(:,2)-max_value);
max_value = max(data(:,3)); 
data(:,3) = abs(data(:,3)-max_value);
max_value = max(data(:,6)); 
data(:,6) = abs(data(:,6)-max_value);
disp("���򻯺�ľ���Ϊ��");
disp(data);
%�����򻯺�ľ������Ԥ�����������ٵ�Ӱ��
avg = repmat(mean(data),r,1);
new_data = data./avg;
%��Ԥ�����ľ���ÿһ�е����ֵȡ��������ĸ����(�鹹��)
Y = max(new_data,[],2);
%�������ָ���ĸ���еĻ�ɫ������
%�Ȱ�new_data��������Ԫ�ض���ȥĸ������ͬ�е�Ԫ�أ���ȡ����ֵ
Y2 = repmat(Y,1,c);
new_data = abs(new_data-Y2);
a = min(min(new_data)); %ȫ������Сֵ
b = max(max(new_data)); %ȫ�������ֵ
ro = 0.5;
new_data = (a+ro*b)./(new_data+ro*b);
disp("����ָ�����ĸ���еĻ�ɫ������Ϊ��");
gamma = mean(new_data);
%�������ָ���Ȩ��
disp("����ָ���Ȩ��Ϊ��");
weight = gamma./(sum(gamma,2));