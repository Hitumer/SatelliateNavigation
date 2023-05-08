% plotdllDiscr( d )
% 
% d......... the Early-Late correlator spacing [Chips]
function plotcoherentdllDiscr( d )

dtau = -2:.001:2; %in chips
dphi = 0; %in rad
df   = 0; %in Hz

CN0abs = 1;
Ti   = 1e-3; %in ms

discrOut = zeros( size(dtau) );

for k=1:length(dtau)
    I_P = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k) )*1*cos(dphi);
    Q_P = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k) )*1*sin(dphi);
    I_E = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)-d/2 )*1*cos(dphi);
    Q_E = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)-d/2 )*1*sin(dphi);
    I_L = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)+d/2 )*1*cos(dphi);
    Q_L = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)+d/2 )*1*sin(dphi);
    
    discrOut(k) = dllDiscr( d, I_P, Q_P, I_E, Q_E, I_L, Q_L );
end

figure( 1 );
hold on;
plot( dtau, discrOut );
ylim([-2 2]);

end


% r = R( dtau )
% returns the correlation of two PRN-codes spaced shifted by dtau
% dtau..... the code-phase offset [Chips]
function r = R( dtau )
r = ( 1-abs(dtau) )*( abs(dtau)<=1 );
end