Ex=0;
En=0.017;
He=0.005;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.b')
axis([0,1,0,1.0])
xlabel('Ȩ��')
ylabel('������')
text(Ex+0.05, 0.8, '����Ҫ')

Ex=0.3;
En=0.033;
He=0.005;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.b')
text(Ex-0.05, 0.8, '����Ҫ')

Ex=0.5;
En=0.033;
He=0.005;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.b')
text(Ex-0.05, 0.8, 'һ����Ҫ')

Ex=0.7;
En=0.033; 
He=0.005;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.b')
text(Ex-0.05, 0.8, '����Ҫ')

Ex=1;
En=0.017; 
He=0.005;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.b')
text(Ex-0.08, 0.8, '�ǳ���Ҫ')

Ex=0.9;
En=0.027; 
He=0.005;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.w')
text(Ex-0.08, 0.8, '�ǳ���Ҫ')


function [x, y] = cal(Ex, En, He)
    Enn = randn(1, 1000)*He+En;
    x = randn(1, 1000).*Enn+Ex;
    y = exp(-(x-Ex).^2./(2*Enn.^2));
end
