% Reading of ephemeris information
% clear all;
addpath include

% Read RINEX ephemerides file and convert to internal Matlab format
year = 2018;
day_of_year = 307;

%gps_week = floor( (datenum(year,1,1)+dayNumber-1 - ...
%    datenum(1980,1,6)) / 7 );
day_of_week = rem(datenum(year,1,1)+day_of_year-1-datenum(1980,1,6),7);

broadcast_filename = sprintf('brdc%03d0.%02dn', day_of_year, mod(year, 100));
rinexe(broadcast_filename ,'eph.dat');
Eph = get_eph('eph.dat');

% Compare the satpos computed with ephmeris data and the IGS orbit
% Hint: Use selectEph.m to find a specific data from Eph




PRNs = [1,2,3,5,6,7,8]; % 4 not available for the sample file

times_in_day_sec = 0:15*60:(60*60); 
err_Eph = zeros(length(times_in_day_sec),length(PRNs));
seconds_in_week = times_in_day_sec + day_of_week*24*3600;


r_ECEF_IGS = zeros(length(times_in_day_sec),3);
r_ECEF_Eph = zeros(length(times_in_day_sec),3);

progressbar('Total', 'PRN', 'Epoch');
figure(3);
for k=1:length(PRNs)
    fprintf('PRN %02.0f\n',PRNs(k));
    progressbar([], (k-1)/length(PRNs), []);
    for i=1:length(times_in_day_sec)
        progressbar(((k-1)+(i-1)/length(times_in_day_sec))/length(PRNs), [], (i-1)/length(times_in_day_sec));
        
        [eph_realtime,tk] = selectEph(Eph, seconds_in_week(i), PRNs(k), true);
        r_ECEF_Eph(i,:) = satpos(seconds_in_week(i),eph_realtime);
        
        r_ECEF_IGS(i,:) = satposIGS(times_in_day_sec(i),year,day_of_year,PRNs(k));
        err_Eph(i,k) = abs(norm(r_ECEF_Eph(i,:) - r_ECEF_IGS(i,:)));
        

    end
end
progressbar(1);

plot(times_in_day_sec/3600,err_Eph,'LineWidth',2);

xlabel('Time [hour]');
ylabel('Absolute Difference [m]');
title( 'Difference between Ephemeris-based and IGS-based position determination' );
legend(num2str(PRNs'));
grid on;