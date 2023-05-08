% Double-difference pseudorange measurements
close all

PRNs = [8,10,28];
nPRNs = length(PRNs);

ranges_all_1 = PRMeasurements('OBET0150reduced.07o',PRNs);
ranges_all_2 = PRMeasurements('UTC20150reduced.07o',PRNs);

%% Compute and plot the single-difference pseudorange measurements 
    SD_all_PRNs = cell(1,nPRNs);
    SD_time = cell(1,2);
    index_all_1 = cell(1,2);
    index_all_2 = cell(1,2);
% figure()
% lgs = cell(1,nPRNs);
    
 for i = 1:nPRNs

     SD_all_PRNs{1,i} = ranges_all_1{1,i}(:,1) - ranges_all_2{1,i}(:,1);
  
 end
 
 % find the common time and the corresponding index
[SD_time{1,1},index_all_1{1,1},index_all_2{1,1}] = intersect(ranges_all_1{1,1}(:,2),ranges_all_1{1,2}(:,2));
[SD_time{1,2},index_all_1{1,2},index_all_2{1,2}] = intersect(ranges_all_1{1,2}(:,2),ranges_all_1{1,3}(:,2));
% 
% legend(lgs)
% title('Single difference')
% xlabel('Epoch[h]')
% ylabel('SD[m]')


%% Compute and plot the double-difference measurements of PRN pairs (8,10) and (10,28) while both satellites in a pair are available
DD_all = cell(1,nPRNs-1);

figure()
lgs = ['(8,28)','(10,28)'];
DD_all{1,1} = SD_all_PRNs{1,1}(index_all_2{1,1},:) - SD_all_PRNs{1,2}(index_all_2{1,1},:);
DD_all{1,2} = SD_all_PRNs{1,2}(index_all_1{1,2},:) - SD_all_PRNs{1,3}(index_all_2{1,2},:);

plot(SD_time{1,1},DD_all{1,1});
hold on
plot(SD_time{1,2},DD_all{1,2});
hold off

legend('(8,28)','(10,28)')
title('Double difference')
xlabel('Epoch[h]')
ylabel('DD[m]')



