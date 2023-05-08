% Estimate the user position and ionospheric delays 
%
% Arguments:
% PR1_corr: Corrected pseudorange observation received with the signal1(f1) (Kx1)
% PR2_corr: Corrected pseudorange observation received with the signal2(f2) (Kx1)
% => !!! The satellite position is NOT considered for these measurements !!!
% x_s: Satellite positions (Kx3)
% w: Weigthing parameters for the pseudorange observations obtained with the satellites (1xK)
%
% Return:
% pos: User position (3x1)
% res: Residual (2Kx1)
% Ihat: Slant ionospheric delay (Kx1)
function [pos, res, Ihat] = estimationIono(PR1_corr, PR2_corr, x_s, w)
f1 = 154.0*10.23e6;
f2 = 120.0*10.23e6;
Omega = 7.292115147*1e-5; % Earth angular velocity, rad/s
c = 299792458;
K=length(PR1_corr);
W = diag(1./w);
C = blkdiag(diag(1./w), diag(1./w));
pos = [0; 0; 0];
Ihat = NaN(K,1);
Hi = zeros(K,4);
x_s_crr = x_s;

q12 = (f1/f2)^2;

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

        % % calculate H matrix
        Hi(j,:) = [e,1];
     end

     % update with Ls
     H = [Hi,eye(K);Hi,q12*eye(K)];     
     xihat = inv(H'*C*H)*H'*C*([PR1_corr+distance_sate;PR2_corr+distance_sate]);
      
     pos = xihat(1:3); 
     Ihat =xihat(5:end);

end
%reture ouput value
pos = pos;
A = H;
% Compute the residual 
res = [PR1_corr;PR2_corr] - A*xihat;

end