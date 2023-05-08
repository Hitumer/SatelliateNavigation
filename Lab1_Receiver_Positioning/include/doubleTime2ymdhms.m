function [year month day hour min sec doy]=doubleTime2ymdhms(time)

JAN61980 = 44244;
JAN11901 = 15385;
SECPERDAY = 86400.0;
LeapMonths  = [0,  31,  60,  91, 121, 152, 182, 213, 244, 274, 305, 335, 366];
NormalMonths= [0,  31,  59,  90, 120, 151, 181, 212, 243, 273, 304, 334, 365];

mjd=floor(time/SECPERDAY)+JAN61980; 
% gpstime.GPSWeek*7+gpstime.secsOfWeek/SECPERDAY+JAN61980;
fractionOfDay=mod(time,SECPERDAY)/SECPERDAY;

daysFromJan11901 = floor( mjd - JAN11901);
numberFourYears = floor(daysFromJan11901/1461);
yearsSoFar = floor(1901 + 4*numberFourYears);
daysLeft = floor(daysFromJan11901 - 1461*numberFourYears);
deltaYears = floor(daysLeft/365) - floor(daysLeft/1460);

year = floor(yearsSoFar + deltaYears);
doy  = floor(daysLeft - 365*deltaYears + 1);
hour = floor(fractionOfDay*24.0);
min  = floor(fractionOfDay*1440.0  - hour*60.0);
sec  = fractionOfDay*86400.0 - hour*3600.0 - min*60.0;

guess = floor(doy*0.032);
more = 0;
if( mod(year,4) == 0 )   % good until the year 2100
  if ((doy - LeapMonths(guess+1+1)) > 0)
    more = 1;
  end
  month = floor(guess + more + 1);
  day = doy - LeapMonths(floor(guess+more+1));
else
  if ((doy - NormalMonths(floor(guess+1+1))) > 0)
    more = 1;
  end
  month = floor(guess + more + 1);
  day = doy - NormalMonths(floor(guess+more+1));
end

%fprintf('time: %d.%d.%d %2d:%2d:%2g (doy=%d)\n', day, month, year, hour, min, sec, doy)