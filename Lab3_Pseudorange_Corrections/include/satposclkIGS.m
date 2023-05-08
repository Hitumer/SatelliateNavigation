% [x_s] = satposIGS( time, year, dayNumber, PRN )
%
% Computes the position of the GPS satellites with the ultra-rapid precise 
% IGS-orbits. The computation is done in batch-mode (for the whole duration
% of the signal).
%
% time.......... the number of seconds since the beginning of the day
% year.......... the year
% dayNumber..... the number of the day inside the year
% PRN........... the PRN of the satellites to be processed
%
% x_s........... the positions of the satellites in the format
%                time 0 -> [ x_0 y_0 z_0  x_1 y_1 z_1  x_2 y_2 z_2 ...]
% dtSat......... the satellite clock correction without the relativistic
%                correction
function [x_s, dtSat] = satposclkIGS( time, year, dayNumber, PRN )

visibleSats = sort(PRN);

weekNumber = floor( (datenum(year,1,1)+dayNumber-1 - ...
    datenum(1980,1,6)) / 7 );
dayOfWeek = rem(datenum(year,1,1)+dayNumber-1-datenum(1980,1,6),7);

% JPL IGS seems to have a latency of about 7 hours, so the day and
% hour has to be rounded and checked. IGS (interpolation!) can only be
% used for about 20 hours in the future.
latency = 7; %[h]
%  "GPS Time [s] of desired start point" + "signal duration [s]"  >
%  "GPS Time [s] of current time" + "latency of IGS ultra-rapid service"
if (weekNumber*604800+time(1)+dayOfWeek*86400) > ...
        (now-datenum(1980,1,6))*24*3600-2*3600+(24-latency)*3600
    % no self-made prediction with IGS should be allowed
    x_s = [];
    dtSat = NaN;
    return;
end
hour = 12;

folder = 'files';
filename = sprintf('igu%d%d_%02d.sp3.Z',weekNumber,dayOfWeek,hour);
%url = sprintf('ftp://igscb.jpl.nasa.gov/pub/product/%d/%s', ...
%    weekNumber,filename);


url = sprintf('ftp://igs.ign.fr/pub/igs/products/%d/%s', ...
    weekNumber,filename);

filepath = fullfile(folder, filename);

% don't download a file if it already exists
if ~exist(filepath(1:end-2),'file')
    oldpath = pwd;
    try
        cd(folder);
        % download the zipped SP3 file
        disp(['Downloading the IGS Orbits ' url]);
        ftpconn = ftp('igs.ign.fr');
%         pasv(ftpconn);
        cd(ftpconn, sprintf('pub/igs/products/%d',weekNumber));
        mget(ftpconn,filename);
        disp(['Unzipping ' filename]);
        dos(['gzip -d ' filename]);
    catch
        disp('Could not download the IGS sp3-Orbit file...');
        x_s = [];
        dtSat = NaN;
        return;
    end
    cd(oldpath);
end
% open the decompressed SP3 file
fid = fopen(filepath(1:end-2),'r');
if fid==-1
    x_s = [];
    dtSat = NaN;
    return;
end

time = time + dayOfWeek*24*3600;

% removes satellites from the visibleSats array which don't exist
[trueVisibleSats] = find_sats( fid, visibleSats );

x = zeros(1,length(trueVisibleSats)*3);
dtSat = zeros(1,length(trueVisibleSats));

% find the six measurements before and after the desired time instant
[offset, t0] = find_first_time( fid, time, weekNumber );

% read the first 12 sat. coordinates and start the interpolation
measurem_points = zeros(12,4*length(trueVisibleSats));
for k=1:12
    measurem_points(k,:) = read_measurements( trueVisibleSats, fid );
end

if size(measurem_points,2)==0
    error('Satellite PRN %d not available as IGS orbit\n',PRN);
end

% the interpolation is done with a 12-point Neville interpolation
% (after 'PPP and Phase-only GPS Time and Frequency transfer' page 2,
%  http://ieeexplore.ieee.org/iel5/4318993/4318994/04319210.pdf)
tx = [(0:11)*15*60+t0]';
% for t = 0:signalLength
t=0;
    for s=1:length(trueVisibleSats)
        x(t+1,(1:3)+3*(s-1)) = [ ...
            neville(tx,measurem_points(:,1+4*(s-1)),time+t), ...
            neville(tx,measurem_points(:,2+4*(s-1)),time+t), ...
            neville(tx,measurem_points(:,3+4*(s-1)),time+t) ];
        dtSat(t+1,s) = neville(tx,measurem_points(:,4+4*(s-1)),time+t);
    end

    if mod(t+1,15*60)==0
        % add a new measurement and remove the oldest
        measurem_points(1:end-1,:) = measurem_points(2:end,:);
        measurem_points(end,:) = read_measurements( trueVisibleSats, fid );
        tx = [tx(2:end) tx(end)+15*60];
    end
% end

% add the zeros-lines for satellites which don't exist
x_s = zeros(1,length(visibleSats)*3);
for k=1:length(trueVisibleSats)
    l = find(visibleSats==trueVisibleSats(k));
    x_s(:,(1:3)+3*(l-1)) = x(:,(1:3)+3*(k-1));
end

x_s = x_s';

% absolute phase center offset (according to
% http://earth-info.nga.mil/GandG/sathtml/gpsdoc2009_08a.html
% (NGA GPS Ephemeris/Station/Antenna Offset Documentation) )
pcv = 1e-3*[
     12.45     -0.38    -22.83 % 01
     -9.90      6.10    -82.00 % 02
    279.40      0.00    951.90 % 03
    279.40      0.00    951.90 % 04
      2.92     -0.05    -16.71 % 05
    279.40      0.00    951.90 % 06
      1.27      0.25      0.56 % 07
    279.40      0.00    951.90 % 08
    279.40      0.00    951.90 % 09
    279.40      0.00    951.90 % 10
      1.90      1.10   1514.10 % 11
    -10.16      5.87    -93.55 % 12
      2.40      2.50   1614.00 % 13
      1.80      0.20   1613.70 % 14
     -9.96      5.79    -12.27 % 15
     -9.80      6.00   1663.00 % 16
     -9.96      5.99   -100.60 % 17
     -9.80      6.00   1592.30 % 18
     -7.90      4.60    -18.00 % 19
      2.20      1.40   1614.00 % 20
      2.30     -0.60   1584.00 % 21
      1.80     -0.90     59.80 % 22
     -8.80      3.50      0.40 % 23
    279.40      0.00    951.90 % 24
    279.40      0.00    951.90 % 25
    279.40      0.00    951.90 % 26
    279.40      0.00    951.90 % 27
      1.90      0.70   1513.10 % 28
    -10.12      5.91    -15.12 % 29
    279.40      0.00    951.90 % 30
      1.60      0.33    -57.50 % 31
    279.40      0.00    951.90 % 32
    ];

for ti=1:length(time)
    x_sun = sunpos( year, dayNumber, time(ti)-dayOfWeek*24*3600 );
%     for k=1:length(trueVisibleSats)
        x_s_tmp = x_s;
        z = -x_s_tmp; z = z/norm(z);         % z-axis of the satellite
        
        s = x_sun - x_s_tmp; s = s/norm(s);  % (unit) vector from the sat. to the sun
        
        y1 = [z'; s'; 0 0 1]\[0;0;1];        % the two possible y-axes
        y2 = -y1;
        
        x1 = cross(y1,z);       % the two possible x-axes
        x2 = -x1;
        
        p1 = dot(x1,s);         % projection of the sun-vector onto the x-axis
                                % choose the result that's positive
        
        if p1 > 0
            x = x1/norm(x1);
            y = y1/norm(y1);
        else
            x = x2/norm(x2);
            y = y2/norm(y2);
        end
        
        x_s = x_s_tmp ...
            + pcv(visibleSats(k),1)*x + pcv(visibleSats(k),2)*y + pcv(visibleSats(k),3)*z;
%     end
end
fclose(fid);

end

% [offset,t0] = find_first_time( fid, t )
% finds the offset of the file 'fid' for the first interpolation measure-
% ment point, which is at most 6*15 minutes apart from the point of the
% interpolation
function [offset,t0] = find_first_time( fid, t, week )
while 1
    line = fgetl(fid);
    if strcmp(line(1:5),'*  20')==1
        [wn time]=getGPSTimeFromDTG(str2num(line(2:end)),0);
        if time+(wn+1024)*604800+6*15*60 > (t+week*604800)
            offset = ftell(fid);
            t0 = round(time-(week-(wn+1024))*604800);
            return;
        end
    end
end

end

% [m] = read_measurements( visibleSats, fid )
% reads the next measurements inside the sp3-file for the satellites
% 'visibleSats'
function [m] = read_measurements( visibleSats, fid )

m = zeros(1,4*length(visibleSats));
for s=1:length(visibleSats)
    line = fgetl(fid);
    while strcmp(line(1:4),sprintf('PG%02d',visibleSats(s)))==0
        line = fgetl(fid);
    end
    data = str2num(line(5:end-8));
    % read the measurements and convert to meter and seconds
    m((1:4)+4*(s-1)) = [data(1:3)*1e3 data(4)*1e-6];
end

end

% [trueVisibleSats] = find_sats( fid, visibleSats )
% adjusts the 'visibleSats' array such that it only contains satellites
% which are actually in space
function [trueVisibleSats] = find_sats( fid, visibleSats )
% the information stands on the 3rd and 4th line
line = fgetl(fid); line = fgetl(fid); line=fgetl(fid);
trueVisibleSats = zeros(str2num(line(5:6)),1);
l = 1;
for k=0:16
    if strcmp(line(10+k*3),'G')
        trueVisibleSats(l) = str2num(line(10+k*3+(1:2)));
        l = l+1;
    end
end
line = fgetl(fid);
for k=0:16
    if strcmp(line(10+k*3),'G')
        trueVisibleSats(l) = str2num(line(10+k*3+(1:2)));
        l = l+1;
    end
end
% check for all real satellites if they are needed
for k=1:length(trueVisibleSats)
    if ~any(find(visibleSats==trueVisibleSats(k)))
        trueVisibleSats(k) = -1;
    end
end
trueVisibleSats = trueVisibleSats(find(trueVisibleSats>0));
end


function [weekNumber time]=getGPSTimeFromDTG(DTG,timeZone)

DTG=datevec(datenum(DTG)-timeZone/24);
% disp('Assuming  daylight saving time...')

weekNumber=floor((floor(datenum(DTG))-730354)/7);
time=mod((datenum(DTG))-730354,7)*24*3600;%+DTG(4)*3600+DTG(5)*60+DTG(6);
end