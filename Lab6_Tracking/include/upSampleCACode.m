%
% code = upSapmleCACode( PRN, f_code, T_code, d, remCodePhase )
%
% upsamples the C/A Code and cyclically shifts it to offer creation of
% early and late versions.
%
% PRN............. PRN of the satellite
% f_code.......... frequency of the C/A code
% d............... the shift in chips
% remCodePhase.... the remainder of the code phase of the previous ms
% settings........ structure containing the settings of the receiver
%
% Returns:
% code............ the upsampled code
% remCodePhase.... the code-phase remainder
%
function [code,remCodePhase] = upSampleCACode( PRN, f_code, d, remCodePhase, settings )

%%--- C/A Code Initialization
caCode = generateCAcode(PRN);
% Then make it easy to do early and late versions
caCode = [caCode(1023) caCode caCode(1)];

T_code = f_code / settings.samplingFreq;

blksize = ceil((1023-remCodePhase) / T_code);

%% Set up all the code phase tracking information -------------------------
% Define index into early code vectortcode       = remCodePhase : ...
tcode  = remCodePhase : T_code : ((blksize-1)*T_code + remCodePhase);
% Define index into early code vector
tcode2 = ceil(tcode+d) + 1;
code   = caCode(mod(tcode2-2,1023)+2);

remCodePhase = mod((tcode(blksize) + T_code),1023);