function satp = satpos_nosincorr(t,eph);
%SATPOS   Calculation of X,Y,Z coordinates at time t
%         for given ephemeris eph

GM = 3.986005e14;             % Earth's universal gravitational parameter m^3/s^2
Omegae_dot = 7.2921151467e-5; % Earth rotation rate, rad/s

%  Units are either seconds, meters, or radians
%  Assigning the local variables to eph

svprn   =   eph(1);
af2     =   eph(2);
M0      =   eph(3);
roota   =   eph(4);
deltan  =   eph(5);
ecc     =   eph(6);
omega   =   eph(7);
cuc     =   eph(8);
cus     =   eph(9);
crc     =  eph(10);
crs     =  eph(11);
i0      =  eph(12);
idot    =  eph(13);
cic     =  eph(14);
cis     =  eph(15);
Omega0  =  eph(16);
Omegadot=  eph(17);
toe     =  eph(18);
af0     =  eph(19);
af1     =  eph(20);
toc     =  eph(21);

num_secs_per_week = 7*24*60*60;

% Extend the function to compute the satellite position without the sinusoinal correction terms at time t using the given eph
warning('Implementation missing.');

end % end of function