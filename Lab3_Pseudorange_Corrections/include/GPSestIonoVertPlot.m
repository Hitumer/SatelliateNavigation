function GPSestIonoVertPlot( Ivhat, iono_model, iono_mapping )

figure(99);
hold on;

title('Ionospheric vertical delay')

descr_str = [iono_model.str() ', ' iono_mapping.str()];

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
ylabel('Ionospheric vertical delay [m]');
end