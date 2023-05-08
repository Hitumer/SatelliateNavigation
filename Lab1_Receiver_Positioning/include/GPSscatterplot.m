function GPSscatterplot( x, xref )

if size(x,1)~=3
    x = x';
end

dx = x - xref * ones(1,size(x,2));

[lambda,phi,h] = togeod(6378137,298.2572236,xref(1),xref(2),xref(3));

R = [ -sin(lambda)          cos(lambda)             0;
    -sin(phi)*cos(lambda)   -sin(phi)*sin(lambda)   cos(phi);
    cos(phi)*cos(lambda)    cos(phi)*sin(lambda)    sin(phi)];

dx_ENU = R*dx;

cm=colormap();
cmindex = ([1:size(cm,1)]-1)/size(cm,1);
colPlot = zeros(size(x,2),3);
for k=1:size(x,2)
    colPlot(k,:) = interp1(cmindex,cm,(k-1)/size(x,2));
end
scatter(dx_ENU(1,:),dx_ENU(2,:),[],colPlot,'.');
title( sprintf(['Scatter plot around true location \n(%2.1f° East / %2.1f° North / %.0fm Height)'], ...
    lambda*180/pi, phi*180/pi, h) );
xlabel('X (East) [m]'); ylabel('Y (North) [m]'); 
hcb = colorbar('YTickLabel',{'First Estimate','Last Estimate'});
set(hcb,'YTickMode','manual');
set(hcb,'YTick',[0 1]);
xlim([-10 10]);
ylim([-10 10]);
grid on;
hold off;