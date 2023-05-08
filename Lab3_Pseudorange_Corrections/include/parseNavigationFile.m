% [ PRN, OrbitP,alpha, beta ] = parseNavigationFile ( filename )
% 
% Parses a Navigation file and stores all the data in OrbitP. PRN contains
% all the numbers of the satllites to which the OrbitP-data are related.
% PRN 1-32:  GPS
% PRN 33:    GIOVE-A
% PRN 34:    GIOVE-B
% PRN 35-84: Galileo (Galileo SV-Nr. 1-50)
% 
% filename...... the name of the Navigation file ( xxxxxxx.yyN )
function [PRN, OrbitP, alpha, beta] = parseNavigationFile( filename )

if ~exist( filename, 'file' )
    % Navigation file doesn't exist!
    PRN=[]; OrbitP=[]; alpha=[]; beta=[];
    error('Navigation File doesnt exist!');
end

try
    fid = fopen( filename, 'r' );
catch
    error('Could not open Navigation File');
end

line = fgetl(fid);
if ~strcmp(line(21),'N')
    % Doesn't seem to be a Navigation file
    PRN=[]; OrbitP=[]; alpha=[]; beta=[];
    error('This is not a Navigation File');
end

rinexVersion = str2num(line(1:9));

% extract the ionospheric correction parameters if they're present
if rinexVersion < 3 && nargout > 2
    [alpha,beta] = parseIono( fid );
else
    alpha = [];
    beta = [];
end

findFirstEntry( fid );

PRN = [];
OrbitP = [];

[p, d] = parseEntry( fid, rinexVersion );
while ~isempty(p)
    PRN = [PRN; p];
    OrbitP = [OrbitP; d];
    [p, d] = parseEntry( fid, rinexVersion );
end

% End of the Navigation file;
fclose(fid);
end

% [alpha,beta] = parseIono( fid )
% parses the navigation to find the ionospheric alpha and beta parameters
% probably present. If the end of the header has been reached without
% finding them, empty matrices are returned.
function [alpha,beta] = parseIono( fid )
line = fgetl(fid);
alpha = [];
beta  = [];
while ~feof(fid) && isempty( strfind(line,'END OF HEADER') ) && ...
        isempty( strfind(line,'ION ALPHA') ) && ...
        isempty( strfind(line,'ION BETA') )
    line = fgetl(fid);
end

if ~isempty( strfind(line,'END OF HEADER') )
    % no iono corrections found
    return;
elseif ~isempty( strfind(line,'ION ALPHA') )
    alpha = sscanf(line(1:60),'%f %f %f %f');
    if length(alpha)==1
        alpha = str2num(line(1:60));
    end
elseif ~isempty( strfind(line,'ION BETA') )
    beta = sscanf(line(1:60),'%f %f %f %f');
    if length(beta)==1
        beta = str2num(line(1:60));
    end
end

line = fgetl(fid);
while ~feof(fid) && isempty( strfind(line,'END OF HEADER') ) && ...
        isempty( strfind(line,'ION ALPHA') ) && ...
        isempty( strfind(line,'ION BETA') )
    line = fgetl(fid);
end

if ~isempty( strfind(line,'END OF HEADER') )
    % no iono corrections found
    return;
elseif ~isempty( strfind(line,'ION ALPHA') )
    alpha = sscanf(line(1:60),'%f %f %f %f');
    if length(alpha)==1
        alpha = str2num(line(1:60));
    end
elseif ~isempty( strfind(line,'ION BETA') )
    beta = sscanf(line(1:60),'%f %f %f %f');
    if length(beta)==1
        beta = str2num(line(1:60));
    end
end

end


% findFirstEntry ( fid )
% finds the first data-entry inside the file opened with pointer 'fid'
function findFirstEntry( fid )
while ~feof(fid)
    line = fgetl(fid);
    if ~isempty( strfind(line,'END OF HEADER') )
        return;
    end
end
end

% [PRN, data] = parseEntry ( line, fid )
% parses an entry in the Navigation file and stores all values in a struct
function [PRN, data] = parseEntry( fid, rinexVersion )

if feof(fid)
    % no more data sets
    PRN=[]; data=[];
    return;
end
line = fgetl(fid);
while sum(abs(str2num(line(2:end))))==0 && ~feof(fid)
    line = fgetl(fid);
end

data = [];
satType = NaN;
if rinexVersion>=3
    s = str2num( line(2:23) );
    if strcmp(line(1),'G')
        satType = 0;
    elseif strcmp(line(1),'E')
        satType = 1;
    end
else
    s = str2num( line(1:22) );
    satType = 0;
end
if size(s,2)~=7 || isnan(satType)
    % Uncompatible data set
    PRN = []; data = [];
    return;
end
PRN = s(1) + 34*satType;

% % GPS Time
% if s(2) >= 80 %Year
%     s(2) = s(2)+1900;
% else
%     s(2) = s(2)+2000;
% end
% time = datenum(s(2:7)) - datenum([1980 01 06 0 0 0]);
% data.week = floor(time/7);
% data.time = (time-data.week*7)*24*3600;

nx = 3+(rinexVersion>=3); % number of whitespaces in front of the data

line = regexprep(line,'[Dd]','e'); % str2double doesn't like D or d as separator for the exponent

% Sat. Clock
data.a_f0 = str2double(line(nx+(20:38))); %[s]
data.a_f1 = str2double(line(nx+(39:57))); %[s/s]
data.a_f2 = str2double(line(nx+(58:76))); %[s/s^2]

% LINE 2
if feof(fid)
    % Incomplete data set
    PRN = []; data = [];
    return;
end
line = fgetl(fid);
line = regexprep(line,'[Dd]','e');

data.IODE_sf2 = str2double(line(nx+(1:19)));
data.C_rs     = str2double(line(nx+(20:38)));  %[m]
data.deltan   = str2double(line(nx+(39:57)));  %[rad/s]
data.M_0      = str2double(line(nx+(58:76)));  %[rad]

% LINE 3
if feof(fid)
    % Incomplete data set
    PRN = []; data = [];
    return;
end
line = fgetl(fid);
line = regexprep(line,'[Dd]','e');

data.C_uc  = str2double(line(nx+(1:19)));   %[rad]
data.e     = str2double(line(nx+(20:38)));  %[]
data.C_us  = str2double(line(nx+(39:57)));  %[rad]
data.rootA = str2double(line(nx+(58:76)));  %[m^.5]

% LINE 4
if feof(fid)
    % Incomplete data set
    PRN = []; data = [];
    return;
end
line = fgetl(fid);
line = regexprep(line,'[Dd]','e');

data.t_oe    = str2double(line(nx+(1:19)));   %[s (of GPS week)]
data.C_ic    = str2double(line(nx+(20:38)));  %[rad]
data.Omega_0 = str2double(line(nx+(39:57)));  %[rad]
data.C_is    = str2double(line(nx+(58:76)));  %[rad]

% LINE 5
if feof(fid)
    % Incomplete data set
    PRN = []; data = [];
    return;
end
line = fgetl(fid);
line = regexprep(line,'[Dd]','e');

data.i_0      = str2double(line(nx+(1:19)));   %[rad]
data.C_rc     = str2double(line(nx+(20:38)));  %[m]
data.omega    = str2double(line(nx+(39:57)));  %[rad]
data.omegaDot = str2double(line(nx+(58:76)));  %[rad/s]

% LINE 6
if feof(fid)
    % Incomplete data set
    PRN = []; data = [];
    return;
end
line = fgetl(fid);
line = regexprep(line,'[Dd]','e');

data.iDot       = str2double(line(nx+(1:19)));  %[rad/s]
data.weekNumber = str2double(line(nx+(39:57))); %[]

% LINE 7
if feof(fid)
    % Incomplete data set
    PRN = []; data = [];
    return;
end
line = fgetl(fid);
line = regexprep(line,'[Dd]','e');

data.health = str2double(line(nx+(20:38)));
if satType==0
    data.T_GD = str2double(line(nx+(39:57)));
else
    data.T_GD = 0;%str2double(line(nx+(58:76)));
end

% LINE 8
if feof(fid)
    % Incomplete data set
    PRN = []; data = [];
    return;
end
fgetl(fid);

% data.time = s(1); %[s (of GPS week)]
data.time = data.t_oe; %[s (of GPS week)]
data.t_oc = data.t_oe;

end
