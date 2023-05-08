% 
% acqFineResults = fineFreqSearch( signal, acqResults, settings )
% 
% Performs an acquisition with a fine frequency resolution and the 
% (given) code delay
% 
% signal.......... the sampled IF-data
% acqResults...... the results of a coarse acquisition (freq. coarse, code
%                  fine)
% settings........ struct containing the receiver settings
% 
% acqFineResults.. fine resolved acquisition results
% 
function acqFineResults = fineFreqSearch( signal, acqResults, settings )

Ts = 1/settings.samplingFreq;
samplesPerCode = round(settings.samplingFreq / ...
                           (1.023e6 / settings.codeLength));
                       
signal0DC = signal - mean(signal);

availPRN = find(acqResults.PRN==1);
for p=1:length(availPRN)
    
    PRN = availPRN(p);
    codePhase = acqResults.codePhase(PRN);

    %--- Generate 10msec long C/A codes sequence for given PRN --------
    caCode = generateCAcode(PRN);

    codeValueIndex = floor((Ts * (1:10*samplesPerCode)) / ...
        (1/1.023e6));
    longCaCode = caCode((rem(codeValueIndex, 1023) + 1));

    %--- Remove C/A code modulation from the original signal ----------
    % (Using detected C/A code phase)
    xCarrier = ...
        signal0DC( round(codePhase*samplesPerCode/1023):(round(codePhase*samplesPerCode/1023) + 10*samplesPerCode-1)) ...
        .* longCaCode;

    %--- Find the next highest power of two and increase by 8x --------
    %    Do a Zero Padding and filling to N=power of 2 (faster computation)
    fftNumPts = 8*(2^(nextpow2(length(xCarrier))));

    %--- Compute the magnitude of the FFT, find maximum and the
    %    associated carrier frequency
    fftxc = abs(fft(xCarrier, fftNumPts));

    uniqFftPts = ceil((fftNumPts + 1) / 2);
    [fftMax, fftMaxIndex] = max(fftxc(5 : uniqFftPts-5));
    %         [fftMax, fftMaxIndex] = max(fftxc(1 : uniqFftPts));

    fftFreqBins = (0 : uniqFftPts-1) * settings.samplingFreq/fftNumPts;

    %--- Save properties of the detected satellite signal -------------
    acqFineResults.carrFreq(PRN)  = fftFreqBins(fftMaxIndex);
    acqFineResults.codePhase(PRN) = codePhase;
    acqFineResults.PRN(PRN) = 1;

    disp( ['PRN ' num2str(PRN) ' - fc=' num2str(acqFineResults.carrFreq(PRN)) ...
        ', tau=' num2str(acqFineResults.codePhase(PRN))] )
end