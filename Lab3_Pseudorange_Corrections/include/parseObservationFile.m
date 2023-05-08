% [ time, r_c, measurements1, measurements2, ... ] = 
%           parseObservationFile ( filename, cols [, Nepoch, considerEF] )
%
% parses a Rinex Observation file 'filename'. Reads out at most Nepoch
% entries defined in cols. measurements which are not present are set as
% NaN. Compatible with Rinex version 2 and version 3. But in version 3 the
% cols has to look different. All the columns should follow a system
% identifiere (i.e. 'G', 'R', 'E', or 'S').
%
% filename........ the Rinex Observation file ( xxxxxxx.yyO )
% cols............ comma-separated list of the wanted measurements (string)
%                  e.g. 'C1,L1' (Rinex 2) 'GC1,GL1' (Rinex 3)
% Nepoch.......... the maximum number of epochs (specify [] if the total
%                  number of stored epochs should be parsed
% considerEF...... if the epoch flag should be considered (default: 0)
%
% returns:
% time............ the time instants of the measurements (2xN: [week; TOW])
% r_c............. the receiver location as encoded in the Rinex-file
% measurements_1.. the measurements corresponding to the first entry in the
%                  <cols> parameter (32xN)
% measurements_2.. the measurements corresponding to the second entry in
%                  the <cols> parameter (32xN)
% ...
%
% (c) 2010, kg
function [time,r_c,varargout] = ...
    parseObservationFile( filename, cols, Nepoch, considerEF )

% check the presence and validity of the Nepoch parameter
if ~exist('Nepoch','var')
    Nepoch = inf;
else
    if isempty(Nepoch)
        Nepoch = inf;
    elseif Nepoch<=0
        Nepoch = inf;
    end
end

% check the presence and validity of the considerEF parameter
if ~exist('considerEF','var')
    considerEF = 0;
else
    if isempty(considerEF)
        considerEF = 0;
    end
end

if ~strcmp( filename(end),'O' ) && ~strcmp( filename(end), 'o' )
    % not a Observation file
    error('This is not an Observation File');
end

if ~exist( filename, 'file' )
    % Observation file doesn't exist!
    error('Observation File doesnt exist!');
end

try
    fid = fopen( filename, 'r' );
catch exception
    error('Could not open Observation File');
end

matfile = strcat(filename, '_', cols, '_', num2str(Nepoch), '.mat');
if exist(matfile, 'file')
    fprintf('Observations already parsed, loading mat file.\n');
    load(matfile);
    return;
end

fprintf('Initializing...\n');

line = fgetl(fid);
if ~strcmpi(line(21),'O')
    % Doesn't seem to be a Observation file
    fclose(fid);
    error('This is not an Observation File');
end

% Rinex version encoded in the first line
rinexVersion = str2double( line(1:9) );

if ~exist('cols','var')
    cols = 'C1,D1,L1';
end

% reads the positions of the wanted measurements. In Rinex version 2 this
% is just a vector, in version 3 this is a matrix 2 x N in the first row
% the satellite systems (1=GPS,2=GLONASS,3=Galileo,4=GEO), in the second
% row the position inside the data of the system.
if rinexVersion >= 3
    [N, nCols] = findPositions3( fid, cols );
else
    [N, nCols] = findPositions2( fid, cols );
end
if N==0
    error('No measurements found');
end

% reads the receiver location
r_c = findLocation( fid );

% determine first the number of epochs in the file to make the memory
% allocation easier and faster for Matlab
findFirstEntry( fid );
if rinexVersion >= 3
    NepochFile = findNumEpochs3( fid );
else
    [NepochFile,y0,m0] = findNumEpochs2( fid, N );
end
findFirstEntry( fid );

if NepochFile < Nepoch
    Nepoch = NepochFile;
end

% memory allocation (saves time in Matlab)
time = zeros(2,Nepoch);
varargout = cell(1,length(nCols));
for n=1:size(nCols,2)
    varargout(n) = {NaN(32,Nepoch)};
end

fprintf('Parsing the observation file...\n');
k  = 0;
while k < Nepoch
    % parse one epoch
    if rinexVersion >= 3
        [t,ef,data] = parseEntry3( fid, nCols );
    else
        [t,ef,data] = parseEntry2( fid, N, nCols, y0, m0 );
    end
    nPRN = size(data,1);
    if nPRN>32 && size(varargout{n},1)==32
        for n=1:length(nCols)
            varargout(n) = {NaN(nPRN,Nepoch)};
        end
    end
    
    k = k+1;
    
    % check if there are valid data read
    if isempty(t)
        break;
    end
    
    % check if the epoch flag was 0 (meaning that the data are valid)
    if ef==0 || ~considerEF
        time(:,k) = t;
        for n=1:size(nCols,2)
            varargout{n}(:,k) = data(:,n);
        end
    end
    if mod(k,10)==0
        fprintf('.');
    end
    if mod(k,40*10)==0
        fprintf('\n');
    end
end

fprintf('\n');
fclose(fid);

for i=1:length(varargout)
    tmp = varargout{i};
    
    tmp(tmp == 0) = NaN;
    varargout{i} = tmp;
end

save(matfile, 'time', 'r_c', 'varargout');
end

% findFirstEntry ( fid )
% 
% finds the first data-entry inside the file opened with pointer 'fid'
function findFirstEntry( fid )
fseek(fid,0,'bof');
while ~feof(fid)
    line = fgetl(fid);
    if ~isempty( strfind(line,'END OF HEADER') )
        return;
    end
end
end

% [Nepoch,y0,m0] = findNumEpochs2( fid, N )
% 
% finds the number of epochs in this file. returns the values of year and
% month found in the first epoch. Rinex version 2.
function [Nepoch,y0,m0] = findNumEpochs2( fid, N )
y0 = NaN;
m0 = NaN;
Nepoch = 0;
while ~feof(fid)
    Nepoch = Nepoch+1;
    line = fgetl(fid);
    if isnan(y0)
        y0 = str2double(line(2:3));
        m0 = str2double(line(5:6));
    else
        while ~feof(fid)
            if length(line)>6
                if str2double(line(2:3))==y0 || str2double(line(5:6))==m0
                    break;
                end
            end
            line = fgetl(fid);
        end
    end
    nSat = str2double(line(30:32));
    for k=1:nSat*ceil(N/5)+ceil(nSat/12)-1
        if feof(fid)
            Nepoch = Nepoch-1;
            return;
        end
        fgetl(fid);
    end
end
end


% [Nepoch] = findNumEpochs3( fid, N )
% 
% finds the number of epochs in this file. Rinex version 3.
function [Nepoch] = findNumEpochs3( fid )
Nepoch = 0;
while ~feof(fid)
    Nepoch = Nepoch+1;
    line = fgetl(fid);
    
    while strcmp(line(1),'>')==0 && ~feof(fid)
        line = fgetl(fid);
    end
    
    nSat = str2double( line(33:35) );
    for k=1:nSat
        if ~feof(fid)
            fgetl(fid);
        else
            return;
        end
    end
end
end

% r_c = findLocation ( fid )
%
% reads the location of the receiver as stated in the Rinex obs. file
function r_c = findLocation( fid )
fseek(fid,0,'bof');
line = fgetl(fid);
k = 0;
while isempty( strfind(line,'APPROX POSITION XYZ') ) && k<1e3 && ~feof(fid)
    line = fgetl(fid);
    k = k+1;
end
if ~isempty( strfind(line,'APPROX POSITION XYZ') )
    r_scan = textscan(line(1:45),'%f %f %f');
    r_c = [ r_scan{1}; r_scan{2}; r_scan{3} ];
else
    r_c = NaN(3,1);
end
end

% [ N, nCols ] = findPositions2 ( fid, cols )
% 
% finds the index of the measurements inside the Rinex file defined by the
% string cols (comma-separated list)
function [N,nCols] = findPositions2( fid, cols )
fseek(fid,0,'bof');
line = fgetl(fid);
while isempty( strfind(line,'TYPES OF OBSERV') ) && ~feof(fid)
    line = fgetl(fid);
end
% check if the while loop breaked because of feof(fid)
if isempty( strfind(line,'TYPES OF OBSERV') )
    N=0; nCols=[];
    return;
end

N = str2double(line(1:6)); % the number of measurements

format=line(7:60);
if N>9 %if multiple lines for the definition of the measurements are used
    line = fgetl(fid);
    format = strcat(format,line(7:60));
end

% find out how many measurements are wanted
if strcmp(cols(end),','), cols = cols(1:end-1); end
if strcmp(cols(1),','), cols = cols(2:end); end
nMeas = length(strfind(cols,','))+1;

nCols = NaN( 1, nMeas );
for k=1:nMeas
    tmp = strfind(format,cols( (k-1)*3+(1:2) ));
    if isempty(tmp)
        nCols(k) = NaN;
        warning('Rinex:NotAllMeasurementsInTheFile',...
            'No %s Information in this file.',cols( (k-1)*3+(1:2) ));
    else
        nCols(k) = (tmp+1)/6;
    end
end

end


% [ N, nCols ] = findPositions3 ( fid, cols )
% 
% finds the index of the measurements inside the Rinex file defined by the
% string cols (comma-separated list)
function [N,nCols] = findPositions3( fid, cols )
fseek(fid,0,'bof');
line = fgetl(fid);
N = zeros(4,1);

% find out how many measurements are wanted
if strcmp(cols(end),',')==0, cols = strcat(cols,','); end
if strcmp(cols(1),',')==0, cols = strcat(',',cols); end
idxComma = strfind(cols,',');
nCols = NaN(2,length(idxComma)-1);
for i=1:length(idxComma)-1
    gnssSys = strfind('GRES',cols(idxComma(i)+1));
    nCols(1,i) = gnssSys;
end

while ~feof(fid) && isempty( strfind(line,'END OF HEADER') )
    line = fgetl(fid);
    
    if ~isempty( strfind(line,'OBS TYPES') )
        gnssSys = strfind('GRES',line(1));
        if isempty(gnssSys)
            continue;
        end
        
        N(gnssSys) = str2double( line(4:6) );
        
        format=line(7:60);
        if N(gnssSys)>13 %if multiple lines for the definition of the meas. are used
            line = fgetl(fid);
            format = strcat(format,line(7:60));
        end
        
        for i=1:size(nCols,2)
            if nCols(1,i)==gnssSys
                p = strfind( format, cols((idxComma(i)+2):(idxComma(i+1)-1)) );
                if isempty(p)
                    nCols(2,i) = NaN;
                else
                    nCols(2,i) = (p-2)/4 + 1;
                end
            end
        end
    end
end

for i=1:size(nCols,2)
    if isnan(nCols(2,i))
        warning('Rinex:NotAllMeasurementsInTheFile',...
            'No %s Information in this file.',cols((idxComma(i)+1):(idxComma(i+1)-1)));
    end
end

end

% [ t, epoch_flag, data ] = parseEntry2 ( fid, N, nCols, y0, m0 )
% 
% reads the next entry of the Rinex Observation file. The data ist stored
% in the data matrix of size 32xlength(nCols). If an entry remains NaN, this
% satellite is not present. t is the GPS Time of this entry of size 2x1,
% representing [week, seconds]. y0 and m0 are used to not getting into
% trouble when there are some unforeseen (e.g. COMMENT) lines in the data.
function [t,epoch_flag,data] = parseEntry2( fid, N, nCols, y0, m0 )
if feof(fid)
    t=[]; epoch_flag=[]; data=[];
    return;
end
line = fgetl(fid);

while ~feof(fid)
    if length(line)>6
        if str2double(line(2:3))==y0 || str2double(line(5:6))==m0
            break;
        end
    end
    line = fgetl(fid);
end

year  = str2double(line(2:3));
month = str2double(line(5:6));
day   = str2double(line(8:9));
hour  = str2double(line(11:12));
minute= str2double(line(14:15));
sec   = str2double(line(16:26));

epoch_flag = str2double(line(29));

% compute GPS Time (week + seconds) for the measurement
if year>=80
    year = year+1900;
else
    year = year+2000;
end
date = (datenum([year month day hour minute sec]) ...
    - datenum([1980 01 06 0 0 0]))*24*3600; % Start of GPS Time
t = [0; 0];
t(1) = floor(date/604800);
t(2) = floor( (date-t(1)*604800)/(24*3600) )*24*3600 + 3600*hour + 60*minute + sec;

% generate a vector for the PRNs
nSat = str2double( line(30:32) );
PRN = zeros(nSat,1);
gpsFlag = 0;
galFlag = 0;
gloFlag = 0;
for k=1:nSat
    if mod(k-1,12)==0 && k>1
        line = fgetl(fid);
    end
    
    kMod = mod(k-1,12);
    PRN(k) = str2double( line( 33+kMod*3+(1:2) ) );
    
    satType = line(33+kMod*3);
    if strcmpi(satType,'R')
        % add 40 to the GLONASS PRNs
        PRN(k) = PRN(k) + 40;
        gloFlag = 1;
    elseif strcmpi(satType,'E')
        % add 70 to the Galileo PRNs
        PRN(k) = PRN(k) + 70;
        galFlag = 1;
    else
        gpsFlag = 1;
    end
end

if gpsFlag==1 && galFlag==0 && gloFlag==0 || ...
        gpsFlag==0 && galFlag==1 && gloFlag==0 || ...
        gpsFlag==0 && galFlag==0 && gloFlag==1
    data = NaN(32, length(nCols));
elseif gpsFlag==1 && galFlag==1 && gloFlag==1
    data = NaN(3*32, length(nCols));
else
    data = NaN(2*32, length(nCols));
end

nColsGood =  ~isnan(nCols) ;
data(PRN,nColsGood) = grabEpoch2( fid, N, length(PRN), nCols(nColsGood) );

end

% data = grabEpoch2 ( fid, Nobs, Nsat, nCols )
%
% reads the data of one epoch into <data>
%
% fid..... file identifier
% Nobs.... the number of observations in this file
% Nsat.... the number of satellites in this epoch
% nCols... the positions of the wanted measurements
function data = grabEpoch2( fid, Nobs, Nsat, nCols )
data = zeros(Nsat,length(nCols));
Nrows = ceil(Nobs/5);

for k=1:Nsat
    totline = char(zeros(1,80*Nrows));
    for l=1:Nrows
        line = fgetl(fid);
        totline( (l-1)*80+(1:length(line)) ) = line;
    end
    for n=1:length(nCols)
        data(k,n) = str2double( totline((nCols(n)-1)*16+(1:14)) );
    end
end
end


% [ t, epoch_flag, data ] = parseEntry3 ( fid, nCols )
% 
% reads the next entry of the Rinex Observation file. The data ist stored
% in the data matrix of size 32xlength(nCols). If an entry remains NaN, this
% satellite is not present. t is the GPS Time of this entry of size 2x1,
% representing [week, seconds].
function [t,epoch_flag,data] = parseEntry3( fid, nCols )
if feof(fid)
    t=[]; epoch_flag=[]; data=[];
    return;
end
line = fgetl(fid);

while ~feof(fid) && strcmp(line(1),'>')==0
    line = fgetl(fid);
end

year  = str2double(line(3:6));
month = str2double(line(8:9));
day   = str2double(line(11:12));
hour  = str2double(line(14:15));
minute= str2double(line(17:18));
sec   = str2double(line(19:29));

epoch_flag = str2double(line(32));

% compute GPS Time (week + seconds) for the measurement
date = (datenum([year month day hour minute sec]) ...
    - datenum([1980 01 06 0 0 0]))*24*3600; % Start of GPS Time
t = [0; 0];
t(1) = floor(date/604800);
t(2) = floor( (date-t(1)*604800)/(24*3600) )*24*3600 + 3600*hour + 60*minute + sec;

K = str2double(line(33:35));
data = grabEpoch3( fid, K, nCols );

end

% data = grabEpoch3 ( fid, Nsat, nCols )
%
% reads the data of one epoch into <data>
%
% fid..... file identifier
% Nsat.... the number of satellites in this epoch
% nCols... the positions of the wanted measurements
function data = grabEpoch3( fid, Nsat, nCols )
data = NaN( 32, size(nCols,2) );

for k=1:Nsat
    if feof(fid)
        data = NaN( 32, size(nCols,2) );
        return;
    end
    
    line = fgetl(fid);
    gnssSys = strfind('GRES',line(1));
    PRN = str2double(line(2:3));
    idxCol = find( nCols(1,:)==gnssSys );
    for i=idxCol
        idxData = (nCols(2,i)-1)*16+3+(1:14);
        if length(line) >= idxData(end)
            data(PRN,i) = str2double( line(idxData) );
        end
    end
end
end