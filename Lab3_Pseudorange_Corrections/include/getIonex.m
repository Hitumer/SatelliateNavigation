% This function downloads a ionex file obtained from IGS, parses it and
% returns the parsed map
%
% Input:
% filename .......... name of the file to be parsed, including path
% Output:
% flag .............. true for successful
% e.g. flag = parseIonex('Z:\MATLAB\Input_-_Raw_data\IONEX\igsg0010.11i')

function [map, lat, lon, time] = getIonex(ac, year, doy)

map = [];
time = [];
lat = [];
lon = [];

folder = 'files';
filename = sprintf('%3sg%03d0.%02di.Z',ac, doy, year-2000);
url = sprintf('ftp://igs.ign.fr/pub/igs/products/ionosphere/%04d/%03d/%s', ...
    year, doy,filename);

filePath_extr = fullfile(folder, filename(1:end-2));

savefilename = [filePath_extr '.mat'];

if exist(savefilename, 'file')
    load(savefilename);
    return;
end

oldpath = pwd;
% don't download a file if it already exists
if ~exist(filePath_extr,'file')
    try
        cd(folder);
        % download the zipped ZPD file
        disp(['Downloading the IGS Ionex file ' url]);
        ftpconn = ftp('igs.ign.fr');
%         pasv(ftpconn);
        cd(ftpconn, sprintf('pub/igs/products/ionosphere/%04d/%03d', ...
                year, doy));
        mget(ftpconn,filename);
        disp(['Unzipping ' filename]);
        dos(['gzip -d ' filename]);
    catch
        disp('Could not download the IGS Ionex file...');
        return;
    end
    cd(oldpath);
end


try
    fid = fopen(filePath_extr, 'r');
catch exception
    error('Could not open IONEX File');
end

line = fgetl(fid);
% Find all the time stamps in the file
map = nan(71, 73, 13); % 1st dimension: latitude87.5to-87.5, 2nd longitude-180to180, 3rd time00to00

lat = (87.5:-2.5:-87.5).';
lon = (-180:5.0:180).';
time = (0:3600:24*3600).';

% find first entry
while ~feof(fid)
    if length(line) > 79
        if strcmp(line(61:76), 'START OF TEC MAP')
            break;
        end
    end
    line = fgetl(fid);
end

line = fgetl(fid);
count = 1;
while ~feof(fid)
    if length(line) > 79
        if strcmp(line(61:80), 'EPOCH OF CURRENT MAP')
            
            for lat_i = 1:71
                % next line is LAT/LON1/LON2/DLON/H
                fgetl(fid);
                for lon_j = 1:4
                    % next line starts the tecv values
                    line = fgetl(fid);
                    map(lat_i, 16*(lon_j-1)+(1:16), count) = 0.1*str2num(line(1:80)); %#ok<*ST2NM> % [TECU]
                end
                % next line starts the last row of tecv values for this lat_i
                line = fgetl(fid);
                map(lat_i, 16*4+(1:9), count) = 0.1*str2num(line(1:45));% [TECU]
            end
            count = count + 1;
        end
    end
    if length(line)>79 && strcmp(line(61:76), 'START OF RMS MAP');
        break;
    end
    
    line = fgetl(fid);
    
end

fclose(fid);

% Save output for next time
save(savefilename, 'map', 'time', 'lat', 'lon');

end
