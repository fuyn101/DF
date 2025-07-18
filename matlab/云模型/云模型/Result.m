Ex=0.7;
En=0.0353; 
He=0.0048;
hold on
[x, y] = cal(Ex, En, He);
plot(x, y, '.b')
axis([0,1,0,1.0])
xlabel('»®÷ÿ')
ylabel('¡• Ù∂»')

function [x, y] = cal(Ex, En, He)
    Enn = randn(1, 1000)*He+En;
    x = randn(1, 1000).*Enn+Ex;
    y = exp(-(x-Ex).^2./(2*Enn.^2));
end