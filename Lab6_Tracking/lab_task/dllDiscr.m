% dtau = dllDiscr( d, I_P, Q_P, I_E, Q_E, I_L, Q_L )
% 
% Inputs:
% d............. Early-Late Spacing [Chips]
% I_P, Q_P...... Inphase and Quadrature prompt components
% I_E, Q_E...... Inphase and Quadrature early components
% I_L, Q_L...... Inphase and Quadrature late components
% 
% Output:
% dtau.......... The error in the code-phase offset

function dtau = dllDiscr( d, I_P, Q_P, I_E, Q_E, I_L, Q_L)

        % conherent DLL 
        % dtau = 1/2*(I_E- I_L) ;
        % Non-conherent DLL

        % early-minus-late power 
        % dtau = ((I_E^2+Q_E^2)-(I_L^2+Q_L^2))/2;
        % dot product power
        % dtau = ((I_E-I_L)*I_P + (Q_E-Q_L)*Q_P)/2;
        % early-minus-late envelope
        % dtau = (sqrt(I_E^2+Q_E^2)-(I_L^2+Q_L^2))/2;

        % Normalization of DLL discriminators
        dtau = (I_E - I_L)/(2*I_P);
        
end