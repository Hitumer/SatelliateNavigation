function [pos, res] = estimationBasic(PR_corr, x_s, w)

c = 299792458;
K=length(PR_corr);
W = diag(1./w);
pos = [0; 0; 0];

x_s_corr = x_s;

for n=1:10
    
    % Estimation of the travel time of the signal
    if n==1
        tt = .07 * ones(K,1);
    else
        tt = sqrt( sum((ones(K,1)*pos'-x_s).^2,2) )/c;
    end
    
    % Compensation for the earth rotation
    for k=1:K
        x_s_corr(k,:) = e_r_corr(tt(k),x_s(k,:)')';
    end

    
    dx = pos*ones(1,K)-x_s_corr';
    e = (dx./(ones(3,1)*sqrt(sum(dx.^2,1))))';
    H = [e ones(K,1)];
    rho_tilde = PR_corr + sum(e.*x_s_corr,2);
    xihat = (H'*W*H)\(H'*W*rho_tilde);
    
    pos_old = pos;
    pos = xihat(1:3);
    
    if norm(pos_old - pos) < 1e-3
        break;
    end
end

res = PR_corr - H*xihat;
end