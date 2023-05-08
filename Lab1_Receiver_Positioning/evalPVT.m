% evalPVT ( stationName, N )
%
% initiates the PVT computation of the station <stationName> by using the
% function calcPVT(). 
%
% stationName... the name of the IGS station
% N............. the number of epochs used
% 
% (c) 2009, kg
function evalPVT( stationName, N )

addpath include

c = 299792458;

% get the observation and navigation file names
clock = [2019, 2, 13];
[obsFile,navFile] = checkRinexFiles( stationName, clock ); % clock 3x1 [year, month, day] % Day#1000: clock=[2016,4,10]

disp('Parsing Navigation file...')
[PRN, OrbitP,alpha,beta] = parseNavigationFile( navFile );
disp('Parsing Observation file...')
[time,r_c,PR,D1] = parseObservationFile( obsFile, 'C1,D1', N );

% ask the user for the satellites to use for computing the geom. matrix
disp('Computing PVT solutions...');

% DOP stuff
hdop = zeros(1,size(time,2));
vdop = hdop;
pdop = hdop;
% the rotation matrix to get H/VDOP
[phi, lambda] = xyz2llh( r_c(1), r_c(2), r_c(3) );
R = blkdiag([ -sin(lambda) cos(lambda) 0; 
    -sin(phi)*cos(lambda) -sin(phi)*sin(lambda) cos(phi); 
    cos(phi)*cos(lambda) cos(phi)*sin(lambda) sin(phi)],1);

azTot = NaN(32,size(time,2));
elTot = NaN(32,size(time,2));
pos   = NaN(3,size(time,2));
vel   = NaN(4,size(time,2));

for k=1:size(time,2)
    if length(find(PR(:,k)))<5
        continue;
    end

    % the satellites that can be used have a non-zero entry
    p = find( ~isnan(PR(:,k)) ); 
    p = intersect( p, PRN );
    
    [x_s, v_s, dtSat] = getSatPos( time(:,k), p, PRN, OrbitP, PR(:,k) );
    
    % the weights after the Black+Eisner Tropospheric Mapping Function
    % (TMF), e.g. in 'Possible Weighting Schemes for GPS Carrier Phase
    % Observations in the Presence Of Multipath'
    [az,el] = lsPos( x_s, PR(p,k) + dtSat*c );
    rho_var = 1.001^2./(.002001+sin(el));
    w = 1./rho_var;
    
    % tropospheric correction
    doy = computeDoY( time(1,k), time(2,k) );
    [tauw,taud] = mopsZenithDelay( r_c(1:3), doy );
    [mw,md] = mopsMappingFunc( el );
    tc  = tauw*mw + taud*md;
    
    % ionospheric correction
    if ~isempty(alpha) && ~isempty(beta)
        ic = calcIonoDelay( time(2,k), alpha, beta, az, el, phi, lambda );
    else
        ic = 0;
    end
    
    % using tropospheric and ionospheric corrections
    [u,v,H] = calcPVT( PR(p,k)+dtSat*c-tc'-ic', D1(p,k), x_s, v_s, w );
    
    Htilde = inv(R*(H'*H)*R');
    hdop(k) = sqrt(sum( diag(Htilde(1:2,1:2)) ));
    vdop(k) = sqrt(Htilde(3,3));
    pdop(k) = sqrt(sum( diag(Htilde(1:3,1:3)) ));

    pos(:,k) = u(1:3,end);
    vel(:,k) = v;
    
    azTot(p,k) = az;
    elTot(p,k) = el;
end

% maybe because of an insufficient number of satellites for certain epochs,
% there might be no PVT solution. These epochs are removed now
pos = pos(:,~isnan(pos(1,:)));
vel = vel(:,~isnan(vel(1,:)));

figure(1);
GPSscatterplot( pos, r_c );
figure(2);
GPSconvergenceplot( u );
figure(3);
GPSerrorplot( pos, r_c, stationName, time(2,2)-time(2,1) );
figure(4);
GPSdopplot( hdop, vdop, pdop, stationName, time(2,2)-time(2,1) );
figure(5);
GPSskyplot( azTot*180/pi, elTot*180/pi, (1:32)', stationName );

% if the velocity has been computed also output some velocity information
if abs(max(max(vel))) > 1e-8
    figure(6);
    GPSvelocityplot( vel(1:3,:), r_c, stationName, time(2,2)-time(2,1) );
end

end


% [x, v, dtSat] = getSatPos ( t, PRN, PRNorbits, o, PR )
% 
% computes the position, velocity and clock correction for the satellites
% 
% t........... time of reception (2x1) / t(1)=WN, t(2)=TOW
% PRN......... the PRN of the satellites to get the information for
% PRNorbits... the PRN of the matching ephemerides in o
% PR.......... the pseudorange measurements for the satellites in <PRN>
function [x, v, dtSat] = getSatPos( t, PRN, PRNorbits, o, PR )

c = 299792458;
x = zeros(length(PRN),3);
v = zeros(length(PRN),3);
dtSat = zeros(length(PRN),1);
ts = zeros(1,length(PRN));

for p=1:length(PRN)
    % find best match for the Parameter-Set
    dt = inf;
    k = 0;
    for l=1:length(PRNorbits)
        if PRNorbits(l)==PRN(p) && abs(t(2) - o(l).time) < dt
            k = l;
            dt = abs(t(2)-o(l).time);
        end
    end

    eph = [PRN(p) ...
        o(k).a_f2 ...
        o(k).M_0 ...
        o(k).rootA ...
        o(k).deltan ...
        o(k).e ...
        o(k).omega ...
        o(k).C_uc ...
        o(k).C_us ...
        o(k).C_rc ...
        o(k).C_rs ...
        o(k).i_0 ...
        o(k).iDot ...
        o(k).C_ic ...
        o(k).C_is ...
        o(k).Omega_0 ...
        o(k).omegaDot ...
        o(k).t_oe ...
        o(k).a_f0 ...
        o(k).a_f1 ...
        o(k).time ...
        o(k).T_GD];

    % correct for the transmission time
    t_sent = t(2) - PR(PRN(p))/c;
    t_sent = t_sent - satclk( t_sent, eph );
    ts(p) = t_sent;
    
    x(p,:) = satpos( t_sent, eph ); % satellite position at transmission time
    v(p,:) = satvel( t_sent, eph ); % satellite velocity at transmission time
    dtSat(p) = satclk( t_sent, eph ); % satellite clock correction at tx time
end

end

% [el,pos] = lsPos( satpos, obs )
% 
% computes a rough position and the corresponding elevation angles of the
% satellites (in radian)
function [az,el,pos] = lsPos( satpos, obs )
c = 299792458;

if size(obs,1)>size(obs,2)
    obs = obs';
end
if size(satpos,1)>size(satpos,2)
    satpos = satpos';
end

nmbOfIterations = 7;

pos     = zeros(4, 1);
X       = satpos;
nmbOfSatellites = size(satpos, 2);

A       = zeros(nmbOfSatellites, 4);
omc     = zeros(nmbOfSatellites, 1);
az      = zeros(1, nmbOfSatellites);
el      = az;

for iter = 1:nmbOfIterations
    for i = 1:nmbOfSatellites
        if iter == 1
            traveltime = 0.070;
            Rot_X = e_r_corr(traveltime,X(:, i));
        else
            traveltime = norm( X(1:3,i)-pos(1:3) ) / c ;

            % Correct satellite position (due to earth rotation)
            Rot_X = e_r_corr(traveltime, X(:, i));
            
            % Compute the elevation in the last iteration
            if iter==nmbOfIterations
                [phi, lambda] = xyz2llh( pos(1), pos(2), pos(3) );
                xENU = llh2enu( phi, lambda, Rot_X - pos(1:3) );

                az(i) = atan2( xENU(1), xENU(2) );
                el(i) = atan2( xENU(3,:), norm(xENU(1:2)) );
            end
        end

        omc(i) = (obs(i) - norm(Rot_X - pos(1:3), 'fro') - pos(4));

        A(i, :) =  [ (-(Rot_X(1) - pos(1))) / obs(i) ...
            (-(Rot_X(2) - pos(2))) / obs(i) ...
            (-(Rot_X(3) - pos(3))) / obs(i) ...
            1 ];
    end % for i = 1:nmbOfSatellites

    if rank(A) ~= 4
        pos     = zeros(1, 4);
        return
    end

    x   = A \ omc;
    pos = pos + x;
end % for iter = 1:nmbOfIterations

end


% returns the vector(s) dx in the local coordinate system (ENU)
% 
% phi........ latitude [rad]
% lambda..... longitude [rad]
% dx......... 3xK [m]
function xENU = llh2enu( phi, lambda, dx )

R = [ -sin(lambda) cos(lambda) 0; 
    -sin(phi)*cos(lambda) -sin(phi)*sin(lambda) cos(phi); 
    cos(phi)*cos(lambda) cos(phi)*sin(lambda) sin(phi)];

xENU = R*dx;
end
