% [ x_uv, v, H ] = calcPVT ( rho_c, rho_rr, u_sv, v_sv, w )
% 
% The function calcPVT computes the LS position solution and velocity for
% given measurements (satellite positions; weight matrix)
% 
% Arguments:
% rho_c : Kx1 column vector of corrected pseudorange measurements
% rho_rr: Kx1 Doppler frquency measurements 
% u_sv  : Kx3 matrix containing the satellite position in each row 
% v_sv  : Kx3 matrix containing the satellite velocity in each row 
% w     : Kx1 weight vector

% Return:
% x_uv  : 4xN matrix, containing a column vector with the user position and
%         clock offset multiplied with the speed of light = [u_uv,
%         c*clock_offset] at each iteration
% v     : 4x1 vector with computed user velocity and clock drift
% H     : Kx4 geometry matrix used for position computation
function [x_uv,v,H]=calcPVT(rho_c, rho_rr, u_sv, v_sv, w)

% Constants
c = 299792458; % Speed of light, m/s
Omega = 7.292115147*1e-5; % Earth angular velocity, rad/s
% fL1 = 1.57542e9;

% The number of the satellites
K=length(rho_c);

% Initialization of the outputs
iter_max = 10;

x_uv=zeros(4,iter_max+1); % => state variables initialized with zeros

% question(3) => state variables initialized with ones(don't effect the result, the
% newton method converge doesn't depend on the initial value)
% x_uv = ones(4,iter_max+1);

v=zeros(4,1);
H = zeros(K,4);

% question(4) add nosie to the  pseudorange measurements rho_c.
% MeanValue = 5;
% Var = 0.1;
% rho_c_noise = rho_c + Var*randn(size(rho_c))+ MeanValue;
% rho_c = rho_c_noise;


u_sv_crr = zeros(K,3); % => corrected satellite position 
Q = diag(1./w); % => covariance matrix

distance_norm = zeros(K,1);
distance_crr = zeros(K,1);
delt_rho = zeros(K,1);
e = zeros(3,1);
Hi = zeros(K,4);
delt_theta = zeros(4,1);
% Iterative LS solution for position and user clock offset estimation
for ni = 1:iter_max

    % Estimation of the signal travel time & Compute the rota
          for j = 1:K

            distance_norm(j) = norm(x_uv(1:3,ni)'-u_sv(j,:));
            tau(j) = distance_norm(j)/c;
            rota(j) = tau(j)*Omega;
    
    % Compensation the earth rotation - u_sv_crr 
            m = R3(rota(j))*u_sv(j,:)';
            u_sv_crr(j,:) = m';
            distance_crr(j) = norm(x_uv(1:3,ni)' - u_sv_crr(j,:));

            
    % LoS vector
            e= (x_uv(1:3,ni)-u_sv_crr(j,:)') / norm(x_uv(1:3,ni)-u_sv_crr(j,:)');
 
            
           % question 5 Add noise to LoS vector (e)
%                if j == 1  
%             
%                         Mean_e = 0.1;
%                          Var_e = 0.1;
%                          
%                          e =e + Var_e*randn(size(e)) + Mean_e;
%                          e= e/norm(e);
%                end
% % 
          
           
    % deltaRho
            
            delt_rho(j) = rho_c(j) - distance_crr(j) -x_uv(4,ni);
    
    % Hi
            Hi(j,:) = [e',1];

         

            end

         
    

         
    % Update
        % update with Ls
           
          delt_theta = inv((Hi'*Hi))*Hi'*delt_rho;
        
        %  question(2) update with WLS
          % delt_theta = inv((Hi'*inv(Q)*Hi))*Hi'*inv(Q)*delt_rho;
            
          
          x_uv(:,ni+1) = delt_theta + x_uv(:,ni); 

end
  
          
 
H = Hi; 


% Additional task: Iterative LS solution for velocity estimation

