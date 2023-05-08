function settings = initSettings()
% Initialize the parameters that are needed for the Acquisition process

% Chip frequency
settings.chipFreq           = 1.023e6;  %[chips/s], cf. normally sampleFreq > chipFreq 

% The number of chips in one C/A code
settings.codeLength         = 1023;     %[chips/code]=[chips/ms]

% List of possible satellites 
settings.acqSatelliteList   = 1:32;     %[PRN numbers]

% Integration interval 
settings.Ti                 = 1;        %[ms] 

% Maximum Doppler shift
settings.maxDoppler         = 6000;     %[Hz]

% ==========================================================
% Change settings.df and settings.dtau to proper values 

% Doppler spacing
settings.df                 = 1160;        %[Hz] 

% Code-phase spacing
settings.dtau               = 1;        %[Tc]


warning('Change settings.df and settings.dtau to proper values!');


end
