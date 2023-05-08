% [obsFile,navFile] = checkRinexFiles ( stationName, t )
% 
% Gets the name of the observation file of the station <stationName> and
% the broadcast ephemerides file of yesterday or any other day
% 
% stationName.. the name of the IGS station
% t............ time in format [year month day hour minute second]
% 
% (c) 2009, kg
function [obsFile,navFile] = checkRinexFiles( stationName, t )

if ~exist('t','var')
    t = clock;
end
year  = t(1);
month = t(2);
day   = t(3);

% get the files of yesterday
dayNumber = datenum(sprintf('%04.0f-%02.0f-%02.0f',year,month,day)) - ...
    datenum(sprintf('%04.0f-01-01',year));

obsFile = sprintf('%s%03.0f0.%02.0fo',stationName,dayNumber,year-2000);
navFile = sprintf('brdc%03.0f0.%02.0fn',dayNumber,year-2000);

% check if the files have already been downloaded and unpacked
if ~exist(obsFile,'file') || ~exist(navFile,'file')
    ftpconn = ftp('cddis.gsfc.nasa.gov');
%     pasv(ftpconn);
    cd(ftpconn, sprintf('gps/data/daily/%04.0f/%03.0f',year,dayNumber));

    if ~exist(obsFile,'file')
        % Observation File
        fprintf('Downloading Observation File for Station -%s-...\n',stationName);
        try
            cd(ftpconn, sprintf('%02.0fo',year-2000));
            mget(ftpconn,[obsFile '.Z']);
            cd(ftpconn, '../');
            dos(['gzip -d ' obsFile '.Z']);
        catch
            error('File not available. Choose different time or station.');
        end
    end

    if ~exist(navFile,'file')
        % Broadcast Navigation File
        fprintf('Downloading Broadcast Ephemerides...\n');
        cd(ftpconn, sprintf('%02.0fn',year-2000));
        mget(ftpconn,[navFile '.Z']);
        dos(['gzip -d ' navFile '.Z']);
    end
    
    close(ftpconn);
end

end