function iv = modelIonoGIM(time, phi_pp, lambda_pp, iono_map, iono_lat, iono_lon, iono_time)

% convert t into seconds of day
t_sec_of_day = mod(time, 24*3600);

% find the two indices around t
indx_before = find(t_sec_of_day-iono_time >= 0.0, 1, 'last');
indx_after  = find(t_sec_of_day-iono_time <= 0.0, 1, 'first');

if isempty(indx_before) || isempty(indx_after)
    % Extrapolating, return NaN instead
    iv = NaN;
    return;
end

iv_t1 = interpolation2d(iono_lat, iono_lon, iono_map(:,:,indx_before), phi_pp, lambda_pp);

if indx_before == indx_after
    % requested point is exactly on one of the sample points, just return
    % that value
    iv = iv_t1;
    return;
end

iv_t2 = interpolation2d(iono_lat, iono_lon, iono_map(:,:,indx_before), phi_pp, lambda_pp);

% Sampling step between the two neigbouring points
dt = iono_time(indx_after)-iono_time(indx_before);

% how far between the points are we (0 means on first point, 1 means on
% second point)
mu = (t_sec_of_day - iono_time(indx_before)) / dt;

iv = (1-mu)*iv_t1 + mu*iv_t2;

end

function int = interpolation2d(lat_data, lon_data, data, lat_req, lon_req)

lat_deg = 180/pi*lat_req;
lon_deg = 180/pi*lon_req;

dlon = mean(diff(lon_data));
dlat = mean(diff(lat_data));

if dlat > 0
    indx_lat = find(lat_data >= lat_deg, 1, 'first') + [-1 ; 0];
else
    indx_lat = find(lat_data <= lat_deg, 1, 'first') + [0 ; -1];
end
% If selected indices go beyond the specified range, copy the most extreme
% value
if any(indx_lat < 1)
    indx_lat = 1.*ones(2,1);
elseif any(indx_lat > length(lat_data))
    indx_lat = length(lat_data).*ones(2,1);
end

if dlon > 0
    indx_lon = find(lon_data >= lon_deg, 1, 'first') + [-1 ; 0];
else
    indx_lon = find(lon_data <= lon_deg, 1, 'first') + [0 ; -1];
end
% If selected indices go beyond the specified range, copy the most extreme
% value
if any(indx_lon < 1)
    indx_lon = 1.*ones(2,1);
elseif any(indx_lon > length(lon_data))
    indx_lon = length(lon_data).*ones(2,1);
end

lat2d = lat_data(indx_lat);
lon2d = lon_data(indx_lon);
    
r_lat = ( lat_deg - lat2d(1) ) / abs(dlat);
r_lon = ( lon_deg - lon2d(1) ) / abs(dlon);

vec_lat = [r_lat, 1-r_lat];
vec_lon = [r_lon; 1-r_lon];
    
arr_2d = reshape(data(indx_lat, indx_lon), 2, 2);
        
int = vec_lat*arr_2d*vec_lon;

end