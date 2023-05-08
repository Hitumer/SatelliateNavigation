% Compute and plot single-difference measurements
close all

PRNs = [8,10,28];
nPRNs = length(PRNs);
ranges_all_1 = PRMeasurements('OBET0150reduced.07o',PRNs);
ranges_all_2 = PRMeasurements('UTC20150reduced.07o',PRNs);
sd = cell(nPRNs,1);
figure()
lgs = cell(nPRNs,1);

for i = 1:nPRNs
    sd{i,1} = ranges_all_1{i} - ranges_all_2{i};
    lgs{i,1} = 'PRN' + string(PRNs(i));
    alldata = ranges_all_1{1,i};
    time = alldata(:,2);
    plot(time,sd{i,1});
    ylim([-62 -60]);
    hold on 
end
hold off
legend(lgs)
title('Single difference')
xlabel('Epoch[h]')
ylabel('SD[m]')




