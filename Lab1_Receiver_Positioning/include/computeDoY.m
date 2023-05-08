% doy = computeDoY( WN, TOW )
% 
% Computes the day of the year, given the week number (WN) and time of week
% (TOW).
% 
% Parameters:
% WN....... week number (since 1980 January 6th)
% TOW...... seconds passed since last sunday 00:00:00h
% 
% Returns:
% doy...... the number of the day of the current year
% 
% (c) 2011, Kaspar Giger
function doy = computeDoY( WN, TOW )

% convert the current time, described by WN and TOW, to a serial date
sd = datenum([1980 1 6 0 0 0]) + 7*WN + floor(TOW/86400);
vd = datevec( sd );

% compute the difference between the date described in vd (as
% [year,month,day,hour,minute,sec] and the first january of the current
% year. Add 1 to it and that's the day of year (one has to be added since
% january 1st will have day number 1).
sd_jan1 = datenum([vd(1) 1 1 0 0 0]);
doy = floor( sd - sd_jan1 ) + 1;