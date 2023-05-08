function GPSerrorplot( x, xref, descr )

if size(x,1)~=3
    x = x';
end

dx = x - xref * ones(1,size(x,2));

[lambda,phi,~] = togeod(6378137,298.2572236,xref(1),xref(2),xref(3));

R = [ -sin(lambda)          cos(lambda)             0;
    -sin(phi)*cos(lambda)   -sin(phi)*sin(lambda)   cos(phi);
    cos(phi)*cos(lambda)    cos(phi)*sin(lambda)    sin(phi)];

dx_ENU = R*dx;
dx_total = sqrt(sum(dx_ENU.^2,1));

figure();
clf;
hold on;

title(['Position error with ' descr])

plot(dx_ENU.', '.-');
plot(dx_total.', '--');

legend('East', 'North', 'Up', 'Total');
fprintf('  mean position error: %f m\n', mean(dx_total, 'omitnan'));

xlim([1 size(x,2)]);
xlabel('Epochs');
ylabel('Position error [m]');
end