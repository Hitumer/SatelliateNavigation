function satp = satpos_nocorr(t,eph);
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

% Extend the function to compute the satellite position without the linear correction term at time t using the given eph
n= sqrt(GM/roota^6);

tk = t - toe;

M = M0 + n*tk;
%value interation of E

max_inter = 10;
E = 0;
for i =1: max_inter

    E = E - (E-ecc*sin(E)-M)/(1-ecc*cos(E));

end

ture_anoma = atan2(sqrt(1-ecc^2)*sin(E),cos(E)-ecc);

theta = ture_anoma + omega;

r = roota^2*(1-ecc*cos(E)) + crc*cos(2*theta) + crs* sin(2*theta);

u = ture_anoma + omega + cuc*cos(2*theta)+cus*sin(2*theta);


r_sorb = [r*cos(u); r*sin(u); 0];

i = i0 + cic*cos(2*theta) + cis* sin(2*theta);

RAAN_omega = Omega0 + (-Omegae_dot)*tk - Omegae_dot*toe;

satp = R3(- RAAN_omega)*R1(-i)*r_sorb;

end % end of function