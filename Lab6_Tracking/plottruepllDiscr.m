% plottruepllDiscr( CN0 )
% 
% CN0....... (optional) Carrier-to-Noise density ratio [dB-Hz]
function plottruepllDiscr( CN0 )

d = 1;

dtau = 0; %in chips
dphi = -pi:.001:pi; %in rad
df   = 0; %in Hz

if ~exist('CN0','var')
    CN0  = 100; %in dB-Hz
end
CN0abs = 10^(CN0/10);
Ti   = 1e-3; %in ms

discrOut = zeros( size(dphi) );

for k=1:length(dphi)
    I_P = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau )*1*cos(dphi(k)) + randn(1);
    Q_P = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau )*1*sin(dphi(k)) + randn(1);
    I_E = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau-d/2 )*1*cos(dphi(k)) + randn(1);
    Q_E = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau-d/2 )*1*sin(dphi(k)) + randn(1);
    I_L = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau+d/2 )*1*cos(dphi(k)) + randn(1);
    Q_L = sinc(df*Ti)*sqrt(2*CN0abs*Ti)*R( dtau+d/2 )*1*sin(dphi(k)) + randn(1);
    
    discrOut(k) = pllDiscr( I_P, Q_P, I_E, Q_E, I_L, Q_L );
end

figure( 4 );
hold on;
grid on;

linecolors = ['b','r','k','m','c','g'];

h = findobj(gca,'Type','line');
plot( dphi, discrOut, linecolors(mod(length(h),6)+1), 'LineWidth', 2 );

% legend handling
h = findobj(gca,'Type','line');
legend(h(1),sprintf('Discriminator (C/N_0=%.0f)',CN0));
legend('off');
legend('toggle');

xlabel('\Delta\phi [rad]');
ylabel('Discriminator Output [rad]');

ylim([-pi/2-1 pi/2+1]);

end


% r = R( dtau )
% returns the correlation of two PRN-codes spaced shifted by dtau
% dtau..... the code-phase offset [Chips]
function r = R( dtau )
r = ( 1-abs(dtau) )*( abs(dtau)<=1 );
end
