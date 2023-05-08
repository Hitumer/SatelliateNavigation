% Estimate the user position and tropospheric delays 
%
% Arguments:
% PR_corr: Corrected pseudorange observation (Kx1)
% => !!! The satellite position is NOT considered for these measurements !!!
% x_s: Satellite positions (Kx3)
% w: Weigthing parameters for the pseudorange observations obtained with the satellites (1xK)
% mw: Mapping function for the wet components (1xK)
% md: Mapping function for the dry components (1xK)
%
% Return:
% pos: User position (3x1)
% res: Residual (2Kx1)
% Tvhat: Vertical tropospheric delay (1x1)
function [pos, res, Tvhat] = estimationTropo(PR_corr, x_s, w, mw, md)
c = 299792458;
K=length(PR_corr);
W = diag(1./w);
pos = [0; 0; 0];
Tvhat = 0;
Omega = 7.292115147*1e-5; % Earth angular velocity, rad/s
Hi = zeros(K,5);
x_s_crr = x_s;

m = mw(:)+md(:);
distance_sate = zeros(K,1);
for n=1:10
     for j = 1:K
        distance_norm(j) = norm(x_s(j,:)-pos');

        tau(j) = distance_norm(j)/c;
        rota(j) = tau(j)*Omega;
        l = [ cos(rota(j)) sin(rota(j)) 0; ...
             -sin(rota(j)) cos(rota(j)) 0; ...
                  0          0          1]*x_s(j,:)';
            
        x_s_crr(j,:) = l';
        distance_crr(j) = norm(pos' - x_s_crr(j,:));
       
        % LoS vector
        e= (pos'-x_s_crr(j,:)) / distance_crr(j);
         
        % rho           
        distance_sate(j,1) = x_s_crr(j,:)*e';

        % calculate H matrix
        Hi(j,:) = [e,1,m(j)];
     end

     % update with Ls
           
     xihat = inv(Hi'*W*Hi)*Hi'*W*(PR_corr+distance_sate);
      
     pos = xihat(1:3); 
     Tvhat =xihat(5);

end
A = Hi;
% Compute the residual
res = PR_corr + distance_sate - A*xihat;

end
