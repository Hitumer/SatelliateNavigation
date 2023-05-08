% [el,pos] = lsPos( satpos, obs )
% 
% computes a rough position and the corresponding elevation angles of the
% satellites (in radian)
function [az,el,pos, llh] = lsPos( satpos, obs )
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
                llh = xyz2llh( pos(1), pos(2), pos(3) );
                phi    = llh(1);
                lambda = llh(2);
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