function GPSvelocityplot( v, xref, stationName, dt )

if size(v,1)~=3
    v = v';
end

[lambda,phi] = togeod(6378137,298.2572236,xref(1),xref(2),xref(3));

R = [ -sin(lambda)          cos(lambda)             0;
    -sin(phi)*cos(lambda)   -sin(phi)*sin(lambda)   cos(phi);
    cos(phi)*cos(lambda)    cos(phi)*sin(lambda)    sin(phi)];

v_ENU = R*v;

plot(v_ENU(1:3,:)');
hold on;
plot( sqrt(sum(v.^2)), 'k.-' );
xlabel(sprintf('Epoch (\\Deltat=%.0fs)',dt));
ylabel('Velocity Error [m/s]')
title(['Velocity for Station: ' stationName]);
legend(sprintf('v_E, \\mu=%.3f , \\sigma_{vE}=%.4f [m/s]',mean(v_ENU(1,:)),std(v_ENU(1,:))), ...
    sprintf('v_N, \\mu=%.3f , \\sigma_{vN}=%.4f [m/s]',mean(v_ENU(2,:)),std(v_ENU(2,:))), ...
    sprintf('v_U, \\mu=%.3f , \\sigma_{vU}=%.4f [m/s]',mean(v_ENU(3,:)),std(v_ENU(3,:))), ...
    ['Absolute Error [m/s]']);
ylim([-1 1]);
grid on;
hold off;

end