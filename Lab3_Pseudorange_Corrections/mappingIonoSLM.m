% Single layer Mapping function
%
% Arguments:
% E: Elevation angle in rad
% h_u: Height of the user in meters
% h_i: Height of the ionospheric layer in meters
% 
% Return:
% im: The computed mapping function value
function im = mappingIonoSLM( E, h_u, h_i )

R_e = 6378136.6; % [m] Equatorial radius of the earth as defined by IAU Almanach 2016

im = 0;

im = asin((R_e+h_u)/(R_e+h_i)*cos(E));

end