%Step1
I1=[];I2=[];I3=[];I4=[];I5=[];   %Iiָi���ȼ�������=ָ��������һ�����ж�ӦcaMbd
%Step2
I=[];
I(:,:,1)=I1;I(:,:,2)=I2;I(:,:,3)=I3;I(:,:,4)=I4;I(:,:,5)=I5;
X=[];           %����ָ�꣬������
W=[];           %Ȩ�أ�����=������  ����Ȩ,��W�������(i,:)����
[a,b]=size(X);  %a=ָ������b=������
%Step3
for i=1:b               %������
    for j=1:a           %ָ����
        x=X(j,i)
        for k=1:5       %�ȼ���
            if x>=I(j,1,k)&&x<I(j,2,k)          %x>=c and x<a
                D(j,k)=-((x-I(j,2,k))/(I(j,1,k)-I(j,2,k)))
            elseif x>=I(j,2,k)&&x<I(j,3,k)      %x>=a and x<M
                D(j,k)=(x-I(j,2,k))/(I(j,3,k)-I(j,2,k))
            elseif x>=I(j,3,k)&&x<I(j,4,k)      %x>=M and x<b
                D(j,k)=(x-I(j,4,k))/(I(j,3,k)-I(j,4,k))
            elseif x>=I(j,4,k)&&x<=I(j,5,k)     %x>=b and x<=d
                D(j,k)=-((x-I(j,4,k))/(I(j,5,k)-I(j,4,k)))
            else
                D(j,k)=-1
            end
        end
    end
    u(:,:,i)=(1+D)/2   %���������uA
end
%a=1,p=1
for i=1:b       %������
    u1(i,:)=1./(1+((W(i,:)*(1-u(:,:,i)))./(W(i,:)*u(:,:,i))))
    h1(i,1)=sum(u1(i,:))
    for k=1:5   %�ȼ���
        H1(i,k)=u1(i,k)*k/h1(i,1)
    end
    H0(i,1)=sum(H1(i,:))
end
%a=2,p=1
for i=1:b       %������
    u2(i,:)=1./(1+((W(i,:)*(1-u(:,:,i)))./(W(i,:)*u(:,:,i))).^2)
    h2(i,1)=sum(u2(i,:))
    for k=1:5   %�ȼ���
        H2(i,k)=u2(i,k)*k/h2(i,1)
    end
    H0(i,2)=sum(H2(i,:))
end
%a=1,p=2
for i=1:b       %������
    W0=diag(W(i,:))
    u3_1=W0*(1-u(:,:,i))
    u3_2=sum(u3_1.^2)
    u3_3=sum((W0*u(:,:,i)).^2)
    u3_4(i,:)=1./(1+(u3_2./u3_3).^0.5)
    h(i,1)=sum(u3_4(i,:))
    for k=1:5   %�ȼ���
        H3(i,k)=u3_4(i,k)*k/h(i,1)
    end
    H0(i,3)=sum(H3(i,:))
end
%a=2,p=2
for i=1:b       %������
    W0=diag(W(i,:))
    u4_1=W0*(1-u(:,:,i))
    u4_2=sum(u4_1.^2)
    u4_3=sum((W0*u(:,:,i)).^2)
    u4_4(i,:)=1./(1+(u4_2./u4_3))
    h(i,1)=sum(u4_4(i,:))
    for k=1:5   %�ȼ���
        H4(i,k)=u4_4(i,k)*k/h(i,1)
    end
    H0(i,4)=sum(H4(i,:))
end