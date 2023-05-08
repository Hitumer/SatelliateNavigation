% postProcessing( fileName, samplingFreq, IF ) 
% Starts the post-processing of recorded IF-data
% 
% Inputs:
% fileName...... the name of the IF-datafile
% samplingFreq.. the sampling frequency of the data
% IF............ the intermediate frequency of the data
%
% * Note that the acquisition results will be stored in the file 'acq.mat'
% afterwards. So if you want to re-run the acquisition, delete this file. 
% 
function postProcessing( fileName, samplingFreq, IF )

addpath include

%% Initialize constants, settings
disp('   Initializing...');

settings = initSettings();
settings.fileName     = fileName;
settings.samplingFreq = samplingFreq;
settings.IF           = IF;

%% Open the file

%--- Check the existance of the specified file
fprintf('   Filename %s\n',fileName);
if ~exist(settings.fileName,'file')
    error('File doesn t exist.');
end

%--- Open the file.
[fid] = fopen(settings.fileName, 'rb');
if ~fid
    error('File couldn t be opened.');
end

%% Acquisition

%--- Find number of samples per spreading code
samplesPerCode = round(settings.samplingFreq / ...
    (settings.chipFreq / settings.codeLength));

%--- Read data for acquisition. 11ms of signal are needed for the fine
%--- frequency estimation
data = fread(fid, 21*samplesPerCode, 'int8')';

%--- Do the acquisition
disp ('   Acquiring satellites...');

if ~exist('acq.mat','file')
    % acqResults = serialsearch(data, settings);
    acqResults = fftsearch(data, settings);

    %--- Do the fine frequency acquisition
    disp ('   Acquiring fine satellite frequencies...');
    acqResultsFine = fineFreqSearch( data, acqResults, settings );

    save 'acq.mat' acqResultsFine;
else
    load 'acq.mat';
    disp('   Loaded the results of previous acquisitions');
end

%--- Start the Tracking
disp ('   Starting the Tracking...');
startTracking( fid, acqResultsFine, settings );

fclose(fid);
