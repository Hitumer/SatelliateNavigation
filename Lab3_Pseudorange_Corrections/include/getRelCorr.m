function dtr = getRelCorr(eph, time)

% Constants
F     = -4.442807633e-10; % Constant, [sec/(meter)^(1/2)]
GM    = 3.986005e14;      % Earth's universal
gpsPi = 3.1415926535898;  % Pi used in the GPS coordinate

%Time correction
tk  = time - eph.t_oe;

%Initial mean motion
n0  = sqrt(GM / eph.rootA^6);
%Mean motion
n   = n0 + eph.deltan;

%Mean anomaly
M   = eph.M_0 + n * tk;
%Reduce mean anomaly to between 0 and 360 deg
M   = rem(M + 2*gpsPi, 2*gpsPi);

%Initial guess of eccentric anomaly
E   = M;

%--- Iteratively compute eccentric anomaly ----------------------------
for ii = 1:10
    E_old   = E;
    E       = M + eph.e * sin(E);
    dE      = rem(E - E_old, 2*gpsPi);

    if abs(dE) < 1.e-12
        % Necessary precision is reached, exit from the loop
        break;
    end
end

%Reduce eccentric anomaly to between 0 and 360 deg
E   = rem(E + 2*gpsPi, 2*gpsPi);

%Compute relativistic correction term
dtr = F * eph.e * eph.rootA * sin(E);

end