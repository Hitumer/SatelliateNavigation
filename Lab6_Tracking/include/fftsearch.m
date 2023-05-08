% [channels] = fftsearch( signal, settings )
% 
% Performs a fft parallel code phase search to acquire the satellites 
% in view
% 
% signal......the sampled IF-data (>=2 ms)
% settings....struct containing the receiver settings 
%             (check initSettings for more details)
% 
% channels....struct containing information about the presence of
%             satellites: 
%              -> channels.PRN: set to 1 if satellites is found
%              -> channels.carrFreq: the carrier frequency for the sat. 
%              -> channels.codePhase: the code phase for the satellites
%                                     [0...1023)
function [channels] = fftsearch( signal, settings )

% Intializes the channels
channels.PRN       = zeros(32,1);
channels.carrFreq  = zeros(32,1);
channels.codePhase = zeros(32,1);

% The number of samples per spreading code interval (or #samples/1ms)
samplesPerCode = round(settings.samplingFreq / ...
    (settings.chipFreq / settings.codeLength));

% Create two consecutive 1ms vectors of data to correlate with
signal1 = signal(1 : samplesPerCode);
signal2 = signal(samplesPerCode+1 : 2*samplesPerCode);

%--- Initialize arrays to speed up the code
% Time Vector
t = (0:samplesPerCode-1)/settings.samplingFreq;

% Vector containing the carrier frequencies to be searched
fVector = settings.IF-settings.maxDoppler : settings.df : settings.IF+settings.maxDoppler;

% Search results of all frequency bins and code shifts (for one satellite),
% twice, for the first and second 1ms piece
Cm1 = zeros(length(fVector),samplesPerCode);
Cm2 = zeros(length(fVector),samplesPerCode);

% Perform search for all PRN numbers ...
for PRN = 1:32

%% Correlate signals ======================================================

    % C/A code at IF
    caCodeIF = caCode(PRN,1e-3,settings);
    FFTcaCodeIF = conj( fft(caCodeIF) );
    
    % Test all the frequencies
    for fIndex = 1:length(fVector)

        % The Carrier for the current frequency
        sinCarr = sin(2*pi*fVector(fIndex)*t);
        cosCarr = cos(2*pi*fVector(fIndex)*t);
        
        signal1noCarrierC = signal1 .* cosCarr;
        signal1noCarrierS = signal1 .* sinCarr;
        signal2noCarrierC = signal2 .* cosCarr;
        signal2noCarrierS = signal2 .* sinCarr;
        
        FFTsignal1 = fft( signal1noCarrierC + j*signal1noCarrierS );
        FFTsignal2 = fft( signal2noCarrierC + j*signal2noCarrierS );
        
        Cm1( fIndex, : ) = abs( ifft( FFTsignal1.*FFTcaCodeIF ) ).^2;
        Cm2( fIndex, : ) = abs( ifft( FFTsignal2.*FFTcaCodeIF ) ).^2;

    end
    
%% Check the presence of the satellite with the current PRN ===============

    % Take the interval which has no bit-transition
    if max(max(Cm1)) > max(max(Cm2))
        Cm = Cm1;
    else
        Cm = Cm2;
    end

    [max1,i11] = max( Cm );
    max2 = findSecondMax( Cm );
    
    if max(max1)/max2 > settings.acqThreshold
        % Satellite is there
        channels.PRN(PRN) = 1;
        
        % Find code phase and carrier freq. 
        [m2,i12] = max(max1);
        channels.carrFreq(PRN)  = fVector( i11(i12) );
        channels.codePhase(PRN) = i12*1023/samplesPerCode;
        
        disp(['PRN ' num2str(PRN) ', fc=' num2str(channels.carrFreq(PRN)) ...
            ', tau=' num2str(channels.codePhase(PRN))]);
    else
        disp(['PRN ' num2str(PRN) ' -']);
    end
end