Ex=50;
En=15; 
He=1;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.b')
axis([0,100,0,1.0])
xlabel('∆¿º€÷µ')
ylabel('¡• Ù∂»')

function [x, y] = cal(Ex, En, He)
    Enn = randn(1, 1000)*He+En;
    x = randn(1, 1000).*Enn+Ex;
    y = exp(-(x-Ex).^2./(2*Enn.^2));
end