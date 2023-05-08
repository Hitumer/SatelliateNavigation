% dphi = pllDiscr( I_P, Q_P, I_E, Q_E, I_L, Q_L )
% 
% Inputs:
% I_P, Q_P...... Inphase and Quadrature prompt components
% I_E, Q_E...... Inphase and Quadrature early components
% I_L, Q_L...... Inphase and Quadrature late components
% 
% Outputs:
% dphi.......... The error in the carrier-phase offset
function dphi = pllDiscr( I_P, Q_P, I_E, Q_E, I_L, Q_L )
        
        % atan-discriminitor
         dphi = atan(Q_P/I_P);
        %I-Q discriminitor
        % dphi = (I_P*Q_P)/(I_P^2 + Q_P^2);

end