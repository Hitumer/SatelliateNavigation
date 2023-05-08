function [zpd, t_zpd] = getIGSTropoZenDelay( station, year, doy )
% ------------------------------------------------------------------------
% [tropoZenDelay, delayTimeStamps] = parseIGSTropoZenDelay( station, year, doy )
%
% Purpose: Download and parse ssssddd0.yyzpd file
%
% Syntax:  [tropoZenDelay, delayTimeStamps] = parseIGSTropoZenDelay( station, year, doy )
%
% Input:   station             - station name
%          year                - year
%          doy                 - day of year
%
% Output:  zpd(i)              - tropospheric zenith delay array in 
%                                units of meters
%          t_zpd(i)            - time tags of the zpd values in seconds
%                                since the start of the day
%          
%
%
% Remarks: Indices:
%          i=1,...,maxepoch           epoch index
%                                     maxepoch= 86400/300 (The trop. zen.
%                                     delays are provided in 300s sampling
%                                     rate.)
%                          
% Author:  Zhibo Wen, NAV
% Date:    07.06.2010
% Changes: 
%          Martin Luelf, NAV    Add time output
% -------------------------------------------------------------------------

folder = 'files';
filename = sprintf('%4s%03d0.%02dzpd.gz',station, doy, year-2000);
url = sprintf('ftp://igs.ign.fr/pub/igs/products/troposphere/%04d/%03d/%s', ...
    year, doy,filename);

filePath_extr = fullfile(folder, filename(1:end-3));

oldpath = pwd;
% don't download a file if it already exists
if ~exist(filePath_extr,'file')
    try
        cd(folder);
        % download the zipped ZPD file
        disp(['Downloading the IGS ZPD file ' url]);
        ftpconn = ftp('igs.ign.fr');
%         pasv(ftpconn);
        cd(ftpconn, sprintf('pub/igs/products/troposphere/%04d/%03d', ...
                year, doy));
        mget(ftpconn,filename);
        disp(['Unzipping ' filename]);
        dos(['gzip -d ' filename]);
    catch
        disp('Could not download the IGS ZPD file...');
        zpd = []; zpd_t = []; return;
    end
    cd(oldpath);
end

if ~strcmp( filePath_extr(end-2:end),'ZPD' ) && ~strcmp( filePath_extr(end-2:end), 'zpd' )
    error('This is not a ZPD File');
end

if ~exist( filePath_extr, 'file' )
    error('ZPD File doesnt exist!');
end

try
    fid = fopen( filePath_extr, 'r' );
    on_exit = onCleanup(@() fclose(fid) );
catch exception
    error('Could not open ZPD File');
end

numEntries = findNumValues( fid, doy );

% Forward to TROP/SOLUTION block
findFirstEntry(fid);

fgetl(fid);
index = 1;

zpd = NaN(numEntries,1);
t_zpd = NaN(numEntries,1);
while ~feof(fid)
    line = fgetl(fid);
    if ~isempty( strfind(line,'-TROP/SOLUTION') )
        break;
    end
    
    time_str = line(7:19);
    doy_entry = str2double( time_str(4:6) );
    
    if(doy_entry == doy)
        t_zpd(index) = str2double(time_str(8:end));
        zpd(index) = str2double(line(19:25))*10^(-3);
        index = index+1;
    end
end

end


% finds the first data-entry inside the file opened with pointer 'fid'
function findFirstEntry( fid )
header = 0;
while ~feof(fid)
    oldOffset = ftell(fid);
    line = fgetl(fid);
    if ~header
        if ~isempty( strfind(line,'TROP/SOLUTION') )
            header = 1;
        end
    else
        fseek(fid,oldOffset,'bof');
        return;
    end
end
end

% finds the first data-entry inside the file opened with pointer 'fid'
function num = findNumValues( fid, doy )
t_Intervall = NaN;

% Read header
fseek(fid, 0, 'bof');

header_line = fgetl(fid);
str_start = header_line(33:45);
str_end   = header_line(46:58);

t_start = date_str_rel_secs( str_start, doy );
t_end   = date_str_rel_secs( str_end  , doy );

if isnan(t_start)
    error('Cannot parse start time ''%s'' of ZPD file', str_start);
end
if isnan(t_end)
    error('Cannot parse end time ''%s'' of ZPD file', str_end);
end
if t_start > t_end
    error('Starting time ''%s'' is after end time ''%s''', str_start, str_end);
end

in_descr_block = false;
while ~feof(fid)
    line = fgetl(fid);
    if ~in_descr_block
        if ~isempty( strfind(line,'+TROP/DESCRIPTION') )
            in_descr_block = true;
        end
    elseif ~isempty( strfind(line,' SAMPLING TROP') )
        t_Intervall = str2double(line(15:end));
        break;
    end
end

% Reset file pointer
fseek(fid, 0, 'bof');


if isnan(t_Intervall)
    error('Cannot parse tropospheric sampling intervall.');
end

num = floor( (t_end-t_start)/t_Intervall );

end

function secs = date_str_rel_secs( date_str, doy_ref )
    
    doy  = str2double( date_str(4:6) );
    secs = str2double( date_str(8:end) );
    
    if abs(doy_ref-doy) > 10
        if doy_ref == 1 && (doy == 365 || doy == 366)
            doy = 0;
        elseif doy == 1 && (doy_ref == 365 || doy_ref == 366)
            doy_ref = 0;
        end
    end
    
    if doy > doy_ref
        % doy after reference day, add number of seconds per day
        if doy-doy_ref > 10
            error('Reported time is more than 10 days away from reference, somthing went wrong here')
        end
        secs = secs + (doy-doy_ref)*(24*3600);
    elseif doy < doy_ref
        % doy before reference day, subtract number of seconds per day
        if doy_ref-doy > 10
            error('Reported time is more than 10 days away from reference, somthing went wrong here')
        end
        secs = secs + (doy-doy_ref)*(24*3600);
    end
        
end