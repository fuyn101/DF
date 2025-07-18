function [Exs, Ens, Hes, result_all] = big_cloud(data, n, m)
% data_num: ÿ��ָ�����������
% indic_num: ָ�������
[data_num, indic_num] = size(data);
fprintf('����ָ��������%d\n', indic_num)
fprintf('ÿ��ָ�������������%d\n', data_num)

% ��ʼ��
Exs = zeros(1, indic_num);
Ens = zeros(1, indic_num);
Hes = zeros(1, indic_num);

% ���μ�����ģ�Ͳ���
for i = 1:indic_num
    % ����� i ��ָ�����ģ�Ͳ���
    [Exs(i),Ens(i),Hes(i)] = my_cloud(data(:,i), n, m);
end

% ���н��
result_all = [Ens; Exs; Hes];

% ��ӡ���
% disp('���������£�')
% disp('Ex: ')
% disp(Exs)
% disp('En: ')
% disp(Ens)
% disp('He: ')
% disp(Hes)
end

function [Ex,En,He] = my_cloud(A,n,m)
%UNTITLED ����ģ�͵�������������
%  �����ɸ��Ƶΰ���SBCT-1stM�㷨���Ex��En��He
%  nΪ��ȡ����������mΪÿ����������Ԫ�ظ�����n��m�ĳ˻���һ��������������
Ex=mean(A);
for i=1:n
    X{i}=datasample(A,m);
    DY(i)=var(X{i});
end
En=sqrt(0.5*sqrt(4*mean(DY).^2-2*var(DY)));
He=sqrt(mean(DY)-En.^2);
end
