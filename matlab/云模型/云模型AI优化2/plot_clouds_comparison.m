% plot_clouds_comparison.m
function plot_clouds_comparison(cloud_array, labels, colors, sizes)
    hold on;
    num_drops = 3000;
    
    for i = 1:length(cloud_array)
        cloud = cloud_array{i};
        En_prime = normrnd(cloud.En, cloud.He, 1, num_drops);
        En_prime(En_prime < 0) = 0;
        x = normrnd(cloud.Ex, En_prime, 1, num_drops);
        y = exp(-(x - cloud.Ex).^2 ./ (2 * En_prime.^2));
        scatter(x, y, sizes(i), 'filled', 'MarkerFaceColor', colors{i}, 'MarkerFaceAlpha', 0.4);
    end
    
    xlabel('评价值', 'FontSize', 12);
    ylabel('隶属度', 'FontSize', 12);
    legend(labels, 'Location', 'northeast', 'FontSize', 10);
    grid on;
    box on;
    xlim([0, 100]);
    ylim([0, 1.1]);
    set(gca, 'FontSize', 11);
    hold off;
end
