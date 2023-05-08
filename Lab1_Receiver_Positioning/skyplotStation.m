% displays the skyplot of an IGS station
function skyplotStation( stationName )

addpath include;

% retrieve the coordinates of the IGS station
r_c = getIGSstationCoordinates( stationName );
[phi, lambda, h] = xyz2llh( r_c(1), r_c(2), r_c(3) );

N  = 2000;    % number of epochs
dt = 30;      % time difference betw. epochs

rinexe('brdc1000.16n','eph.dat');
Eph = get_eph('eph.dat');

indPRN = find(Eph(end,:)==518400);
PRN    = Eph(1,indPRN);

K = length(PRN);

satPositions = zeros( 3, K );
el = zeros( K, N );
az = zeros( K, N );
for n=1:N
    % Compute the Satellite Positions
    for k=1:K
        satPositions(:,k) = satpos( (n-1)*dt+7200, ...
            [Eph(:,indPRN(k));zeros(22-size(Eph,1),1)] );
    end
    
    % Initialization of the Iteration
    H  = zeros(K,3);
    tt = 70e-3*ones(K,1);

    % Iterative determination of the geometry matrix
    for iter = 1:7
        for k = 1:K
            Rot_X = e_r_corr(tt(k),satPositions(:,k));
            dx = norm(Rot_X - r_c);
            tt(k) = dx / 299792458;
            H(k,:) =  [ r_c(1)-Rot_X(1) r_c(2)-Rot_X(2) r_c(3)-Rot_X(3) ] / dx;
        end
    end
    
    % transformation of the unit vectors to a local coordinate systems
    xENU = llh2enu( phi, lambda, -H' );
    az(:,n) = atan2( xENU(1,:), xENU(2,:) )'*180/pi;
    hor_dis = sqrt( sum(xENU(1:2,:).^2) );
    el(:,n) = atan2( xENU(3,:), hor_dis )*180/pi;
    
    % remove the entries with negative elevation
    negElev = find( el(:,n) < 0 );
    az(negElev,n) = NaN( size(negElev) );
    el(negElev,n) = NaN( size(negElev) );
    
    if mod(n,100)==0
        fprintf('%3.0f / %3.0f\n',n,N);
    end
end

for k=1:K
    skyplot(az(k,:),el(k,:),'-'); hold on;
end
title( ['Skyplot of Station ' stationName] );

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
