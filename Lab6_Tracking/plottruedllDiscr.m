% plottruedllDiscr( d, CN0 )
% 
% d......... the Early-Late correlator spacing [Chips]
% CN0....... (optional) Carrier-to-Noise density ratio [dB-Hz]
function plottruedllDiscr( d, CN0 )

dtau = -2:.001:2; %in chips
dphi = 0; %in rad
df   = 0; %in Hz

if ~exist('CN0','var')
    CN0  = 50; %in dB-Hz
end
CN0abs = 10^(CN0/10);
Ti   = 1e-3; %in ms

discrOut = zeros( size(dtau) );

for k=1:length(dtau)
    I_P = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k) )*1*cos(dphi) + randn(1);
    Q_P = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k) )*1*sin(dphi) + randn(1);
    I_E = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)-d/2 )*1*cos(dphi) + randn(1);
    Q_E = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)-d/2 )*1*sin(dphi) + randn(1);
    I_L = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)+d/2 )*1*cos(dphi) + randn(1);
    Q_L = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)+d/2 )*1*sin(dphi) + randn(1);
    
    discrOut(k) = dllDiscr( d, I_P, Q_P, I_E, Q_E, I_L, Q_L );
end

figure( 3 );
hold on;
grid on;

linecolors = ['b','r','k','m','c','g'];

h = findobj(gca,'Type','line');
plot( dtau, discrOut, linecolors(mod(length(h),6)+1), 'LineWidth', 2 );

% legend handling
h = findobj(gca,'Type','line');
legend(h(1),sprintf('Discriminator (d=%.1f, C/N_0=%.0f)',d,CN0));
legend('off');
legend('toggle');

xlabel('\Delta\tau [Chips]');
ylabel('Discriminator Output [Chips]');

ylim([-2 2]);

end


% r = R( dtau )
% returns the correlation of two PRN-codes spaced shifted by dtau
% dtau..... the code-phase offset [Chips]
function r = R( dtau )
r = ( 1-abs(dtau) )*( abs(dtau)<=1 );
end
