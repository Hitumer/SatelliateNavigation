% Find the pseudorange measurements with the selected PRNs 
% and plot pseudoranges[m] over time[h]
function ranges_all = PRMeasurements(filename, PRNs)
addpath include;

% Reading the measurements
disp('Reading measurements...');

nPRNs = length(PRNs);
ranges_all = cell(1,nPRNs);

M = cell2mat(READ_GPS_DATA(filename));

% M matrices
% size: N epochs x 11
% column 1: year
% col  2: month
% col  3: day
% col  4: hour
% col  5: minute
% col  6: second
% col  7: PRN 
% col  8: pseudorange
% col  9: phase
% col 10: doppler [Hz]
% col 11: signal strength

figure()
hold on
lgs = cell(nPRNs,1);
times_all = cell(1,nPRNs);

for i = 1:nPRNs
    lgs{i,1} = 'PRN' + string(PRNs(i));
    Index_PRN = find(M(:,7)==PRNs(i));
    ranges_all{1,i} = M(Index_PRN,8);
    times_all{1,i} = M(Index_PRN,3)*24*60*60*60+M(Index_PRN,4)*60*60+M(Index_PRN,5)*60+M(Index_PRN,6);
    times_all{1,i} = times_all{1,i} - min(times_all{1,i});
    plot(times_all{1,i},ranges_all{1,i});
    ranges_all{1,i} =[ranges_all{1,i},times_all{1,i}];
   
end
hold off
legend(lgs)
title(sprintf('Pseudoranges (%s)',filename))
xlabel('Epoch[h]')
ylabel('PR[m]')

end