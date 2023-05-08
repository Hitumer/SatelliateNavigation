function GPSdopplot( hdop, vdop, pdop, stationName, dt )

hdop = real(hdop);
vdop = real(vdop);
pdop = real(pdop);

plot( hdop, 'b' );
hold on
plot( vdop, 'r' );
plot( pdop, 'k' );
title(sprintf('Dilution of Precision for Station %s',stationName));
xlabel(sprintf('Epoch (\\Deltat=%.0fs)',dt));
ylabel('DOP');
legend( sprintf('HDOP (\\mu=%.3f)',mean(hdop)), ...
    sprintf('VDOP (\\mu=%.3f)',mean(vdop)), ...
    sprintf('PDOP (\\mu=%.3f)',mean(pdop)) );
ylim([0,6]);
hold off;

end