
%��ԭʼ���ݼ���������Ex��En��He
Ex_x = [0.7698 0.986 1.2127 1.399];
En_x = [0.0609 0.0834 0.0677 0.0565];
He_x = [0.01 0.01 0.01 0.01];
%��ԭʼ���ݼ���������Ex��En��He
Ex_y = [0.00062 0.003 0.0075 0.00935];
En_y = [0.00025 0.0013 0.0017 0.0004];
He_y = [0.01 0.01 0.01 0.01];
%�Ƶθ���
n = 5000;
%��ͼ
figure(1)
for i = 1:length(Ex_x)
    for j = 1:n
        %������EnΪ����ֵ��He^2Ϊ�������̬���En'
        En1_x = normrnd(En_x(i),He_x(i),1);
        En1_y = normrnd(En_y(i),He_y(i),1);
        %������ExΪ����ֵ��En'^2Ϊ�������̬���x
        x(j) = normrnd(Ex_x(i),En1_x,1);
        y(j) = normrnd(Ex_y(i),En1_y,1);
        
        uxy(j) = exp(-( x(j)-Ex_x(i))^2/(2*(En1_x^2)) - ( y(j)-Ex_y(i))^2/(2*(En1_y^2)));
    end
    scatter3(x,y,uxy,'.')
    xlim([-inf inf])
    ylim([-inf inf])
    hold on
end
legend({'����','����','����','����'},'Location','NorthEast')



