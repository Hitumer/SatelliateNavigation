% Compute the ionospheric pierce point
function [phi_pp, lambda_pp, psi_pp] = computeIPP(phi_u, lambda_u, el, az, h_i)

R_e = 6378136.6; % [m] Equatorial radius of the earth as defined by IAU Almanach 2016

nadir = asin( R_e/(R_e+h_i) * cos(el) );

psi_pp = pi/2 - el - nadir;

phi_pp = asin( sin(phi_u)*cos(psi_pp) + cos(phi_u)*sin(psi_pp).*cos(az) );
lambda_pp = lambda_u + asin( (sin(psi_pp).*sin(az)) ./ cos(phi_pp) );

end