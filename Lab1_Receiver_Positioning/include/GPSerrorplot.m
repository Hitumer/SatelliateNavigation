function GPSerrorplot( x, xref, stationName, dt )

if size(x,1)~=3
    x = x';
end

dx = x - xref * ones(1,size(x,2));

[lambda,phi,h] = togeod(6378137,298.2572236,xref(1),xref(2),xref(3));

R = [ -sin(lambda)          cos(lambda)             0;
    -sin(phi)*cos(lambda)   -sin(phi)*sin(lambda)   cos(phi);
    cos(phi)*cos(lambda)    cos(phi)*sin(lambda)    sin(phi)];

% Removal of outliers but only if some valid solutions seem to be there
if prctile( abs([dx(1,:) dx(2,:) dx(3,:)]), 10 ) < 100
    goodindices = find( abs(dx(1,:))<1e3 & abs(dx(2,:))<1e3 & abs(dx(3,:))<2e2 );
else
    goodindices = 1:size(dx,2);
end

dx_ENU = R*dx;
dx_nan = NaN( size(dx) );
dx_nan(:,goodindices) = dx(:,goodindices);
dx_ENU_nan = NaN( size(dx) );
dx_ENU_nan(:,goodindices) = dx_ENU(:,goodindices);

plot(dx_ENU_nan(1:3,:)');
hold on
plot( sqrt(sum(dx_nan.^2)), 'k.-' );
xlabel(sprintf('Epoch (\\Deltat=%.0fs)',dt));
ylabel('Error [m]')
title(['Station: ' stationName]);
legend(sprintf('e_E, \\mu=%.3f, \\sigma=%.3f [m]', mean(dx_ENU(1,goodindices)), std(dx_ENU(1,goodindices))), ...
    sprintf('e_N, \\mu=%.3f, \\sigma=%.3f [m]', mean(dx_ENU(2,goodindices)), std(dx_ENU(2,goodindices))), ...
    sprintf('e_U, \\mu=%.3f, \\sigma=%.3f [m]', mean(dx_ENU(3,goodindices)), std(dx_ENU(3,goodindices))), ...
    'Absolute Error [m]');
grid on;
ylim([-20 20]);
hold off;

end