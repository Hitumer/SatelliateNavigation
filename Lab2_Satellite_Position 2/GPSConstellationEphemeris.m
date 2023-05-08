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

for k = 1:32
    
warning('Implementation missing.');
end

xlabel('X[m]');
ylabel('Y[m]');
zlabel('Z[m]');

plotGlobe;
grid on;