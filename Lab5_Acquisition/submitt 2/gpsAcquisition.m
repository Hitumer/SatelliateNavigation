% gpsAcquisition( filename, samplingFreq, IF )
%
% initiates the acquisition of GPS satellites. 
% 
% filename...... the name of the file containing the IF-data
% samplingFreq.. the sampling frequency [Hz]
% IF............ the intermediate frequency [Hz]

function acqResults = gpsAcquisition( fileName, samplingFreq, IF )
close all
addpath include

disp('Initializing...');

settings = initSettings();

settings.fileName     = fileName;
settings.samplingFreq = samplingFreq;
settings.IF           = IF;

% Check if the file exists
if ~exist(settings.fileName,'file')
    error('File doesn t exist.');
end

% Open the file
[fid] = fopen(settings.fileName, 'rb');

% Check if the opening was successful
if fid==0
    error('File could not be opened.');
end

% Acquisition
samplesPerCode = round(settings.samplingFreq / ...
    (settings.chipFreq / settings.codeLength));

% Read data for the acquisition. Read enough data such that it contains two
% 10ms-interval
data = fread(fid, 22*samplesPerCode, 'int8')';

% Run the acquisition
disp ('Acquiring satellites...');

 acqResults = serialsearch(data, settings);
% acqResults = pfssearch(data, settings);
% acqResults = pcssearch(data, settings);

fclose(fid);