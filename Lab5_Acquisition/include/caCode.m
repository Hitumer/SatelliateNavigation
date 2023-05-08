function ca = caCode( PRN, settings )
% Returns the C/A code for satellite PRN, of duration Ti and 
% for the receiver with the settings settings.
% 
% Inputs:
% PRN: [1..32] the number of the PRN
% settings: struct containing the receiver settings

caCodesTable = makeCaTable(settings);
ca = caCodesTable(PRN,:);