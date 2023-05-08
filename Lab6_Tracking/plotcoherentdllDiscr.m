% plotcoherentdllDiscr( d, CN0 )
% 
% d......... the Early-Late correlator spacing [Chips]
% CN0....... (optional) Carrier-to-Noise density ratio [dB-Hz]

function plotcoherentdllDiscr( d, CN0 )

dtau = -2:.001:2; %in chips
dphi = 0; %in rad
df   = 0; %in Hz

if ~exist('CN0','var')
    CN0  = 1e3; %in dB-Hz
end
CN0abs = 10^(CN0/10);
Ti   = 1e-3; %in ms

discrOut = zeros( size(dtau) );
earlyOut = discrOut;
lateOut  = discrOut;

for k=1:length(dtau)
    A = sinc(df*Ti)*sqrt(2*CN0abs*Ti);
    
    I_P = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k) )*1*cos(dphi) + randn(1);
    Q_P = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k) )*1*sin(dphi) + randn(1);
    I_E = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)-d/2 )*1*cos(dphi) + randn(1);
    Q_E = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)-d/2 )*1*sin(dphi) + randn(1);
    I_L = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)+d/2 )*1*cos(dphi) + randn(1);
    Q_L = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau(k)+d/2 )*1*sin(dphi) + randn(1);
    
    earlyOut(k) = I_E/A;
    lateOut(k)  = -I_L/A;
    discrOut(k) = dllDiscr( d, I_P/A, Q_P/A, I_E/A, Q_E/A, I_L/A, Q_L/A );
end

figure( 1 );
hold on;
grid on;

linecolors = ['b','r','m','c','g'];

h = findobj(gca,'Type','line');
if length(h) >= 3
    % remove old early-late correlation plots
    delete(h(2));
    delete(h(3));
end
plot( dtau, earlyOut, 'k--', 'LineWidth', 1 );
plot( dtau, lateOut, 'k--', 'LineWidth', 1 );
plot( dtau, discrOut, linecolors(mod(length(h),6)+1), 'LineWidth', 2 );

% legend handling
h = findobj(gca,'Type','line');
legend(h(1),sprintf('Discriminator (d=%.1f, C/N_0=%.0f)',d,CN0));
legend(h(2),sprintf('Early (d=%.1f)',d));
legend(h(3),sprintf('Late (d=%.1f)',d));
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
