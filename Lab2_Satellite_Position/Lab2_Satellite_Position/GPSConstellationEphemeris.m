% Reading of ephemeris information
% clear all;

addpath include;

% Read RINEX ephemerides file and convert to internal Matlab format
do_realtime_processing = false;
rinexe('brdc3070.18n','eph.dat');
gps_week = 2025;
day_of_week = 0; % Sunday
Eph = get_eph('eph.dat');

Omegae_dot = 7.2921151467e-5; % Earth rotation rate, rad/s

figure(2);
clf;
hold on;

% Compute the positions of each available satellite for the entire day,
% then plot the coordinates with plot3(x,y,z);




times = day_of_week*24*3600 + (0:60:24*3600); % for one day from the starting point

availSats = unique(Eph(1,:)); % PRN of available satellites
r_ECEF = zeros(length(availSats),length(times),3); % positions of available satellites
r_orb = zeros(length(availSats),length(times),3);
for k = 1:length(availSats)
    for i = 1:length(times)
   
        r_ECEF(k,i,:) = satpos(times(i),Eph(:,k));
        r_ECEF_crr = [r_ECEF(k,i,1), r_ECEF(k,i,2),r_ECEF(k,i,3)];
        r_orb(k,i,:) = R3(-times(i)*Omegae_dot)*r_ECEF_crr';

    end
plot3(r_orb(k,:,1),r_orb(k,:,2),r_orb(k,:,3));

end

xlabel('X[m]');
ylabel('Y[m]');
zlabel('Z[m]');

plotGlobe;
grid on;