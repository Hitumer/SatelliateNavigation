function GPSconvergenceplot( u )

if size(u,2) > size(u,1)
    u = u';
end

plot( u(:,1:3) );
xlabel('Iteration Step');
ylabel('Estimation [m]');
legend('x-Coordinate','y-Coordinate','z-Coordinate');
title('Convergence of the Newton Algorithm');

end