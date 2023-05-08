% ca = caCode( PRN, Ti, settings )
% 
% returns the C/A code for satellite PRN, of duration Ti and 
% for the receiver with the settings settings.
% 
% PRN.......[1..32] the number of the PRN
% Ti........the duration of the code [s]
% settings..struct containing the receiver settings
function ca = caCode( PRN, Ti, settings )

caCodesTable = makeCaTable(settings);
ca = caCodesTable(PRN,:)'*ones(1,floor(Ti/1e-3));
ca = [ca(:)', caCodesTable(PRN,1:round(rem(Ti,1e-3)*settings.samplingFreq))];