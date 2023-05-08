% Compute the zenith path delay from IGS ZPD
%
% t............. time of estimation in gps seconds
% zpd........... zenith path delay above the station in meters
% t_zpd......... time tags of zpd delays in seconds since the start of day
%
% tau_total..... total zenith path delay above the station at the time of
%                estimation. Will return NaN when ZPD does not support the
%                requested time (extrapolating)
function tau_total = modelTropoIGSZenithDelay( t, zpd, t_zpd )

% convert t into seconds of day
t_sec_of_day = mod(t, 24*3600);

%% Matlab implementation
% tau_total = interp1(t_zpd, zpd, t_sec_of_day, 'linear');

%% Our own implementation

% sort ZPDs in time so the next one in time is the next one in the array
[t_zpd_sorted, sort_indx] = sort(t_zpd);
zpd_sorted = zpd(sort_indx);

% find the two indices around t
indx_before = find(t_sec_of_day-t_zpd_sorted >= 0.0, 1, 'last');
indx_after  = find(t_sec_of_day-t_zpd_sorted <= 0.0, 1, 'first');

if isempty(indx_before) || isempty(indx_after)
    % Extrapolating, return NaN instead
    tau_total = NaN;
    return;
end

if indx_before == indx_after
    % requested point is exactly on one of the sample points, just return
    % that value
    tau_total = zpd_sorted(indx_after);
    return;
end

% Sampling step between the two neigbouring points
dt = t_zpd_sorted(indx_after)-t_zpd(indx_before);

% how far between the points are we (0 means on first point, 1 means on
% second point)
mu = (t_sec_of_day - t_zpd(indx_before)) / dt;

tau_total = (1-mu)*zpd_sorted(indx_before) + mu*zpd_sorted(indx_after);
end