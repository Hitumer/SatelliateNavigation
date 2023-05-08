% Reading of ephemeris information
clear all;

% Read RINEX ephemerides file and convert to internal Matlab format
rinexe('brdc3070.18n','eph.dat');
gps_week = 2025;
day_of_week = 0; % Sunday
Eph = get_eph('eph.dat');
times = day_of_week*24*3600 + (0:60:60*120); % for one day from the starting point

tmax_min = 120; 

% Analyse the impact of the linear and sinusoidal
%       corrections on the orbital error

r_ECEF_All_Corrections = zeros(121,3);
r_ECEF_No_Linear       = zeros(121,3);
r_ECEF_No_Sinusoiddal  = zeros(121,3);
r_ECEF_No_Corrections  = zeros(121,3);

err_Eph = zeros(121,3);

PRNs = [32];

figure(4);
clf;
hold on;
xlabel('Time [min]');
ylabel('Absolute Difference [m]');
title( 'Difference between the corrected and uncorrected positions' );

for p= PRNs
    fprintf('PRN %02.0f\n',p);
    
    indexPRN = find(Eph(1,:)==p);
    [m,bestIndex] = min( Eph(end,indexPRN) );
    bestIndex = indexPRN( bestIndex);
    
    for i=1:(tmax_min+1)
        r_ECEF_All_Corrections(i,:) = satpos(times(i),Eph(:,bestIndex));
        r_ECEF_No_Linear(i,:) = satpos_nolincorr(times(i),Eph(:,bestIndex));
        err_Eph(i,1) = norm(r_ECEF_All_Corrections(i,:) - r_ECEF_No_Linear(i,:));
        r_ECEF_No_Sinusoiddal(i,:) = satpos_nosincorr(times(i),Eph(:,bestIndex));
        err_Eph(i,2) = norm(r_ECEF_All_Corrections(i,:) - r_ECEF_No_Sinusoiddal(i,:));
        r_ECEF_No_Corrections(i,:) = satpos_nocorr(times(i),Eph(:,bestIndex));
        err_Eph(i,3) = norm(r_ECEF_All_Corrections(i,:) - r_ECEF_No_Corrections(i,:));
    end

    plot([0:tmax_min],err_Eph,'LineWidth',2); hold on;
end


legend('Without linCorr','Without sinCorr','Without corr');
grid on;