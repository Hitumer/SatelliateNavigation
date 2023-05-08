function settings = initSettings()

%% Processing settings ====================================================
settings.msToProcess        = 800;        %[ms]
settings.numberOfChannels   = 1;


%% Code parameters ========================================================
% code stuff
settings.chipFreq           = 1.023e6;      %[Hz]
settings.codeLength         = 1023;

%% Acquisition settings ===================================================
settings.acqSatelliteList   = 1:32;         %[PRN numbers]

% Defines the Carrier Frequency bins to be searched
settings.df                 = 500;      %[Hz]
settings.maxDoppler         = 7000;     %[Hz]

% Defines the Code-Phase spacing
settings.dtau               = 1;        %[Tc]

% Threshold for the signal presence decision rule
settings.acqThreshold       = 2.5;

%% Tracking settings ======================================================
% Early-Late spacing
settings.d                  = 1;        %[Tc]
