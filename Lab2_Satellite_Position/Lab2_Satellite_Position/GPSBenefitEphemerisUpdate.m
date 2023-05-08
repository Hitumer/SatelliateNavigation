% Reading of ephemeris information
clear all;
addpath include;

% Read RINEX ephemerides file and convert to internal Matlab format
rinexe('brdc3070.08n','eph.dat');
gps_week = 2025;
day_of_week = 0; % Sunday
Eph = get_eph('eph.dat'); 

% Analyse the benefit of ephemeris updates

times = day_of_week*7*24*3600 + [0:60:120*60];
times2 = day_of_week*7*24*3600 + [0:60:120*60];
r_ECEF_Eph0AM = zeros(121,3);
r_ECEF_Eph2AM = zeros(121,3);

err_Eph = zeros(121,1);

PRN = 1:32;


index0AM = find(Eph(end,:)==0);
index2AM = find(Eph(end,:)==7200);
PRNlegend = Eph(1,index0AM);
tmax_min = 120; % 

figure(5);
clf;
hold on;

xlabel('Time [min]');
ylabel('Absolute difference of the satpos computed with 2h-old data and the current data [m]');
title( 'Benefit of ephmeris update every two hours' );

for p=PRN
    fprintf('PRN %02.0f\n',p);
    p0 =find(Eph(1,index0AM)==p);
    p2 =find(Eph(1,index2AM)==p);
    
    if isempty(p0)||isempty(p2)
        continue
    
    end


    for i = 1:tmax_min+1
        r_ECEF_Eph0AM(i,:) = satpos(times(i)+2*60*60,Eph(:,index0AM(p0)));
        r_ECEF_Eph2AM(i,:) = satpos(times2(i)+2*60*60,Eph(:,index2AM(p2)));
        err_Eph(i) = norm(r_ECEF_Eph0AM(i,:) - r_ECEF_Eph2AM(i,:));
    end


    plot([0:tmax_min],err_Eph, 'LineWidth',2);
end


legend(num2str(PRNlegend'));
grid on;
