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