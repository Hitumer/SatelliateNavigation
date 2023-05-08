% testPLL( N, dphi, df, CN0 )
% 
% evaluates the PLL described by the functions pllDiscr() and
% pllLoopFilter(). 
% 
% N...... the number of Ti-intervals
% dphi... the initial carrier-phase offset [rad]
% df..... the initial carrier-frequency offset [Hz]
% CN0.... (optional) Carrier-to-Noise density ratio [dB-Hz]
function testPLL( N, dphi, df, CN0 )

Ti = 1e-3;
fs = 1e5;
f0 = 1e4;
fi = f0 + df;
fl = 0;

if ~exist('CN0','var')
    CN0  = 100; %in dB-Hz
end
CN0abs = 10^(CN0/10);

phi0 = dphi;
remCarrPhase = 0;
t = 0:1/fs:Ti;

h = zeros(1,4);
phasehat = zeros(1,N+1);
fhat = zeros(1,N+1);
fhat(1) = f0;

for k=1:N
    rx = cos( 2*pi*fi*( t(1:end-1)+(k-1)*t(end) ) + phi0 );
    
    I_P = sqrt(2*CN0abs*Ti) ...
        * sum( rx.*cos( 2*pi*(fl+f0)*t(1:end-1) + remCarrPhase ) )*2/length(rx) ...
        + randn(1);
    Q_P = sqrt(2*CN0abs*Ti) ...
        * sum( rx.*-sin( 2*pi*(fl+f0)*t(1:end-1) + remCarrPhase ) )*2/length(rx) ...
        + randn(1);
    
    remCarrPhase = rem( 2*pi*(fl+f0)*t(end) + remCarrPhase, 2*pi );

    pd = pllDiscr( I_P, Q_P, 0, 0, 0, 0 );
    
    [fl,h] = pllLoopFilter( pd, h );
    
    if k > 1
        phasehat(k+1) = phasehat(k) + 2*pi*fl*t(end);
    else
        phasehat(k+1) = 2*pi*fl*t(end);
    end
    fhat(k+1) = fl+f0;
end

linecolors = ['b','r','k','m','c','g'];

figure(1);
subplot(2,1,1);
hold on;
h = findobj(gca,'Type','line');
t = (0:N)*t(end);
plot( 1e3*t, phi0 + 2*pi*t*df - phasehat, linecolors(mod(length(h),6)+1) );
xlabel('Time [ms]')
ylabel('Carrier Phase Error [rad]');

subplot(2,1,2);
hold on;
plot( 1e3*t, fi - fhat, linecolors(mod(length(h),6)+1) );
xlabel('Time [ms]')
ylabel('Carrier Frequency Error [Hz]');
