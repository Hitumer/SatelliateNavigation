function [dtSat] = satclk(t, eph)
%% Initialize constants ===================================================
% GPS constatns

gpsPi          = 3.1415926535898;  % Pi used in the GPS coordinate
c              = 299792458;
% system

%--- Constants for satellite position calculation -------------------------
Omegae_dot     = 7.2921151467e-5;  % Earth rotation rate, [rad/s]
GM             = 3.986005e14;      % Earth's universal
% gravitational parameter,
% [m^3/s^2]
F              = -4.442807633e-10; % Constant, [sec/(meter)^(1/2)]

svprn   =   eph(1);
af2     =   eph(2);
M0      =   eph(3);
sqrtA   =   eph(4);
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
T_GD    =  eph(22);

%% Process each satellite =================================================

prn = svprn;

%% Find initial satellite clock correction --------------------------------

%--- Find time difference ---------------------------------------------
dt = t - toe;

time = t;

%% Find satellite's position ----------------------------------------------

%Restore semi-major axis
a   = sqrtA * sqrtA;

%Time correction
tk  = time - toe;

%Initial mean motion
n0  = sqrt(GM / a^3);
%Mean motion
n   = n0 + deltan;

%Mean anomaly
M   = M0 + n * tk;
%Reduce mean anomaly to between 0 and 360 deg
M   = rem(M + 2*gpsPi, 2*gpsPi);

%Initial guess of eccentric anomaly
E   = M;

%--- Iteratively compute eccentric anomaly ----------------------------
for ii = 1:10
    E_old   = E;
    E       = M + ecc * sin(E);
    dE      = rem(E - E_old, 2*gpsPi);

    if abs(dE) < 1.e-12
        % Necessary precision is reached, exit from the loop
        break;
    end
end

%Reduce eccentric anomaly to between 0 and 360 deg
E   = rem(E + 2*gpsPi, 2*gpsPi);

%Compute relativistic correction term
dtr = F * ecc * sqrtA * sin(E);

dtSat = (af2 * dt + af1) * dt + af0 - T_GD + dtr;
