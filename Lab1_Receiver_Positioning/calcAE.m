% [ A, E ] = calcAE ( r_sv, r_u )
% 
% computes azimuth and elevation for the satellite at position r_sv and
% the receiver location r_u
function [A, E] = calcAE( r_sv, r_u ) 

finv = 298.257223563;
a = 6378137;

% transformation into elliptical coordinate system
% lambda, phi in [rad]
[lambda,phi] = togeod(a,finv,r_u(1),r_u(2),r_u(3));

% Additional task: Compute azimuth and elevation angles
warning('Implementation missing.');
