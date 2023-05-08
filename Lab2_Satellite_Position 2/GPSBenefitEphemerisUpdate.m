% Reading of ephemeris information
clear all;
addpath include;

% Read RINEX ephemerides file and convert to internal Matlab format
rinexe('brdc3070.08n','eph.dat');
gps_week = 2025;
day_of_week = 0; % Sunday
Eph = get_eph('eph.dat'); 

% Analyse the benefit of ephemeris updates

r_ECEF_Eph0AM = zeros(121,3);
r_ECEF_Eph2AM = zeros(121,3);

err_Eph = zeros(121,1);

PRN = 1:32;
PRNlegend = PRN;

index0AM = find(Eph(end,:)==0);
index2AM = find(Eph(end,:)==7200);

tmax_min = 120; % 

figure(5);
clf;
hold on;

xlabel('Time [min]');
ylabel('Absolute difference of the satpos computed with 2h-old data and the current data [m]');
title( 'Benefit of ephmeris update every two hours' );

for p=PRN
    fprintf('PRN %02.0f\n',p);
    
warning('Implementation missing.');
    plot([0:tmax_min],err_Eph, 'LineWidth',2);
end


legend(num2str(PRNlegend'));
grid on;
