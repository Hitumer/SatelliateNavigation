function [eph, tk] = selectEph(Ephs, t, PRN, is_realtime)
% The matrix Eph contains all available ephemeris data sets. These datasets
% contain multiple satellites and have data for an entire day. To compute
% the satellite position at time t we need to select one column from Eph
% and return it.
%
% Inputs:
% Ephs .......... 21xN matrix of N ephemeris datasets
% t ............. Scalar time for which a column should be selected in
%                 seconds of the gps week.
% PRN ........... Scalar PRN number of the satellite for which the dataset
%                 should be selected.
% is_realtime ... Logical flag on whether to do the processing in realtime
%                 (true) or in post processing (false).
%
% Output:
% eph ........... 21x1 vector with the selected dataset

row_indx_PRN = 1;
row_indx_toe = 21;

num_sec_per_week = 7*24*60*60;

% Remove all entries that have a different PRN number than the satellite we
% are interested in
Ephs(:,Ephs(row_indx_PRN,:) ~= PRN) = [];

% find best Ephemeris column based on time difference between time
% of computation and time of ephemeris
delta_t = t-Ephs(row_indx_toe,:);

% If ephemeris data that is more than half a week away from the time point
% we are interested it is from the previous/next week, so perform a roll-
% over
delta_t(delta_t >  num_sec_per_week/2) = delta_t(delta_t >  num_sec_per_week/2) - num_sec_per_week;
delta_t(delta_t < -num_sec_per_week/2) = delta_t(delta_t < -num_sec_per_week/2) + num_sec_per_week;

if is_realtime == true
    % Real time, ephemeris data has to be in the past (t_oe <= t) since
    % we can't know what values we will get in the future.
    % So delta_t has to be positive
    delta_t(delta_t < 0) = NaN;
    [tk, column_indx] = min(delta_t);
    if isnan(tk)
        error('Ephemeris data is only available in the future');
    end
    tk = abs(tk);
else
    % Post processing, we actually can look into the "future" (which at the
    % time of porcessing also lies in the past) delta_t can be negative.
    [tk, column_indx] = min(abs(delta_t));
end

eph = Ephs(:,column_indx);


end % end of selectEph function