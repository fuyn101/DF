Ex=0.1063;
En=0.0708;
He=0.01;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.r')
axis([0,1,0,1.0])
xlabel('»®÷ÿ')
ylabel('¡• Ù∂»')
text(Ex+0.05, 0.8, '¢Ò')

Ex=0.3130;
En=0.0670;
He=0.01;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.b')
text(Ex-0.05, 0.8, '¢Ú')

Ex=0.5546;
En=0.0941;
He=0.01;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.c')
text(Ex-0.05, 0.8, '¢Û')

Ex=0.7840;
En=0.0589; 
He=0.01;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.m')
text(Ex-0.05, 0.8, '¢Ù')

Ex=0.9362;
En=0.0426; 
He=0.01;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.y')
text(Ex-0.08, 0.8, '¢ı')



function [x, y] = cal(Ex, En, He)
    Enn = randn(1, 1000)*He+En;
    x = randn(1, 1000).*Enn+Ex;
    y = exp(-(x-Ex).^2./(2*Enn.^2));
end
