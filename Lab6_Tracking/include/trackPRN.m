% [Ip, Qp, f_carr_ret, f_code_ret ] = trackPRN( fid, PRN, deltatau, ...
%                                                        fc, settings)
% 
% fid.............. pointer to the opened IF-datafile
% PRN.............. the PRN number of the satellite to be tracked
% deltatau......... the code delay for the corresponding satellite
% fc............... the carrier frequency for the corresponding satellite
% settings......... structure containing the settings of the receiver
% 
% Ip............... vector containing the Inphase-components for all times
% Qp............... Quadrature-components
% f_carr_ret....... vector containing the carrier frequencies for all times
% f_code_ret....... vector containing the code frequencies for all times
function [Ip,Qp,f_carr_ret,f_code_ret,codeDiscr] = trackPRN( fid, PRN, deltatau, fc, settings )

N  = settings.msToProcess;   % Number of Milliseconds to process

Ip = zeros(N,1);
Qp = zeros(N,1);
f_carr_ret = zeros(N,1);
f_code_ret = zeros(N,1);
codeDiscr  = zeros(N,1);

d = settings.d; % Correlator spacing [Chips]

h_carr = zeros(1,4);
h_code = zeros(1,4);

f_carr = fc;                % (acquired) Carrier Frequency [Hz]
f_code = settings.chipFreq; % (initial) Code Frequency [Hz]

% Reads up to the ending of the acquired code
deltatau = deltatau*round(settings.samplingFreq/1e3)/1023; % deltatau in number of samples
fseek(fid, round(deltatau)-1,'bof');

remCodePhase = 0;
remCarrPhase = 0;

for n=1:N

    % Update the phasestep based on code freq (variable) and
    % sampling frequency (fixed)
    T_code = f_code / settings.samplingFreq;  % [1/Samples]
    blksize = ceil((1023-remCodePhase) / T_code);

    % Read in the appropriate number of samples to process this
    % interation
    [rawSignal, samplesRead] = fread(fid, blksize, 'int8');
    if samplesRead < blksize
        break;
    end
    rawSignal = rawSignal';  %transpose vector

    %% Set up all the code phase tracking information ---------------------
    % Define index into early code vector
    earlyCode  = upSampleCACode( PRN, f_code, -d, remCodePhase, settings );
    lateCode   = upSampleCACode( PRN, f_code, d, remCodePhase, settings );
    [promptCode,remCodePhase] = upSampleCACode( PRN, f_code, 0, remCodePhase, settings );

    %% Generate the carrier frequency to mix the signal to baseband -------
    time    = (0:blksize) ./ settings.samplingFreq;

    % Get the argument to sin/cos functions
    trigarg = (2*pi*f_carr*time) + remCarrPhase;
    remCarrPhase = rem(trigarg(blksize+1), 2*pi);

    % Finally compute the signal to mix the collected data to bandband
    carrCos = cos(trigarg(1:blksize));
    carrSin = sin(trigarg(1:blksize));

    %% Generate the six standard accumulated values -----------------------
    % First mix to baseband
    qBasebandSignal = carrCos .* rawSignal;
    iBasebandSignal = carrSin .* rawSignal;

    % Now get early, late, and prompt values for each
    I_E = sum(earlyCode  .* iBasebandSignal);
    Q_E = sum(earlyCode  .* qBasebandSignal);
    I_P = sum(promptCode .* iBasebandSignal);
    Q_P = sum(promptCode .* qBasebandSignal);
    I_L = sum(lateCode   .* iBasebandSignal);
    Q_L = sum(lateCode   .* qBasebandSignal);

    %% Find PLL error and update carrier NCO ----------------------------------

    % Implement carrier loop discriminator (phase detector)
    dphi = pllDiscr( I_P, Q_P, 0, 0, 0, 0 );
    dtau = dllDiscr( d, I_P, Q_P, I_E, Q_E, I_L, Q_L );
    
    [df_carr, h_carr] = pllLoopFilter( dphi, h_carr );
    [df_code, h_code] = dllLoopFilter( dtau, h_code );

    % Modify code freq based on NCO command
    f_code = 1.023e6 - df_code;
    f_carr = fc + df_carr;

    Ip(n) = I_P;
    Qp(n) = Q_P;
    f_carr_ret(n) = f_carr;
    f_code_ret(n) = f_code;
    codeDiscr(n) = dtau;
    
    disp( sprintf('%d / %d ms',n,N) )
end
