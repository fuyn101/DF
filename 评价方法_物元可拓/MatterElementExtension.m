R1=[];%经典域
A1=[R1(:,1)+R1(:,2)];A11=[R1(:,2)-R1(:,1)];
A2=[R1(:,2)+R1(:,3)];A22=[R1(:,3)-R1(:,2)];
A3=[R1(:,3)+R1(:,4)];A33=[R1(:,4)-R1(:,3)];
A4=[R1(:,4)+R1(:,5)];A44=[R1(:,5)-R1(:,4)];
R0=[];%待评物元,样本Xi为列向量，i=1至样本个数
W0=[];%权重，Xi的权重Wij为行向量，j=1至指标个数
E0=[];
for i=1:51
    R=R0(:,i)
    W=W0(i,:)
    D=[abs(R-A1/2)-A11/2 abs(R-A2/2)-A22/2 abs(R-A3/2)-A33/2 abs(R-A4/2)-A44/2]
    E=[1-1/30*W*D]
    E0(i,:)=[E]
end