function GPSestIonoPlot( Ihat, iono_model )

figure();
clf;
hold on;

K = size(Ihat,2);

title(['Ionospheric slant values for ' iono_model.str()])

for k=1:K
    if any(~isnan(Ihat(:,k)))
        plot(Ihat(:,k), 'DisplayName', sprintf('PRN %2d', k));
    end
end

legend(gca, 'show');


xlim([1 size(Ihat,1)]);
xlabel('Epochs');
ylabel('Ionospheric slant delay [m]');
end