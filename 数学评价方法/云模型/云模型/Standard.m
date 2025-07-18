Ex=0.0655;
En=0.04367;
He=0.01;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.r')
axis([0,1,0,1.0])
xlabel('∆¿º€÷µ')
ylabel('¡• Ù∂»')


Ex=0.2655;
En=0.08967;
He=0.01;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.m')

Ex=0.5919;
En=0.12793;
He=0.01;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.b')

Ex=0.8919;
En=0.07207; 
He=0.01;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.g')

box on;
function [x, y] = cal(Ex, En, He)
    Enn = randn(1, 1000)*He+En;
    x = randn(1, 1000).*Enn+Ex;
    y = exp(-(x-Ex).^2./(2*Enn.^2));
end
