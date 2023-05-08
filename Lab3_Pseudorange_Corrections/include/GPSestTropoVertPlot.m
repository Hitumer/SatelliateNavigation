function GPSestTropoVertPlot( Ivhat, tropo_model, tropo_mapping )

figure(98);
hold on;

title('Tropospheric vertical delay')
descr_str = [tropo_model.str() ', ' tropo_mapping.str()];

h = findobj('DisplayName', descr_str);
if ~isempty(h)
    h.YData = Ivhat;
else
    plot(Ivhat, 'DisplayName', descr_str);

    legend(gca, 'off');
    legend(gca, 'show');
end

xlim([1 length(Ivhat)]);
xlabel('Epochs');
ylabel('Tropospheric vertical delay [m]');
end