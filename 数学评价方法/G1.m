%�˴��Ǹ���ָ��������ϵ
p_relationship=[1,2,4,8,3,6,7,5];
%�˴�������󣬸���ָ������ֵ ȡֵ�� 1  1.2 1.4 1.6 1.8
p_relative=[1.1 1.1 1.1 1.1 1.1 1];
%�˴������ռ���õ���Ȩ��
p_weight=[0,0,0,0,0,0,0];
%����ʹ�����ϵ������
%pȨ�ؼ���
p_relative_multiply=1;
p_relative_sum=0;
for k=2:7
   for j=k:7
       p_relative_multiply=p_relative_multiply*p_relative(j-1);
   end
   p_relative_sum=p_relative_sum+p_relative_multiply;
   p_relative_multiply=1;
end
p_weight(7)=1/(1+p_relative_sum);
p_weight(6)=p_weight(7)*p_relative(6);
p_weight(5)=p_weight(6)*p_relative(5);
p_weight(4)=p_weight(5)*p_relative(4);
p_weight(3)=p_weight(4)*p_relative(3);
p_weight(2)=p_weight(3)*p_relative(2);
p_weight(1)=p_weight(2)*p_relative(1);