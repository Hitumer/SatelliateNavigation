function [m_d,m_w] = mappingNiell(E, lat, doy, height)

% Mapping function of dry and wet tropospheric zenith delay
% Input:
%         E         - elevation angle 	[radians]
%         lat       - latitude          [radians]
%         doy       - day of year
%         height    - height of user    [m]
% Output:
%         m_d       - dry mapping function
%         m_w       - wet mapping function

% modified : Zhibo Wen, Nav
% 27.07.2011

% transform into degrees
latdeg = lat*180/pi;
if latdeg > 0
    Dmin = 28;
else
    Dmin = 211;
    latdeg  = -latdeg;
end

% Grid points for latitude = {15, 30, 45, 60, 75}
ad_grid_bar = [1.2769934e-3, 1.2683230e-3, 1.2465397e-3, 1.2196049e-3, 1.2045996e-3];
bd_grid_bar = [2.9153695e-3, 2.9152299e-3, 2.9288445e-3, 2.9022565e-3, 2.9024912e-3];
cd_grid_bar = [62.610505e-3, 62.837393e-3, 63.721774e-3, 63.824265e-3, 64.258455e-3];

Ad_grid = [0.0, 1.2709626e-5, 2.6523662e-5, 3.4000452e-5, 4.1202191e-5];
Bd_grid = [0.0, 2.1414979e-5, 3.0160779e-5, 7.2562722e-5, 11.723375e-5];
Cd_grid = [0.0, 9.0128400e-5, 4.3497037e-5, 84.795348e-5, 170.37206e-5];

% wet
aw_grid = [5.8021897e-4, 5.6794847e-4, 5.8118019e-4, 5.9727542e-4, 6.1641693e-4];
bw_grid = [1.4275268e-3, 1.5138625e-3, 1.4572752e-3, 1.5007428e-3, 1.7599082e-3];
cw_grid = [4.3472961e-2, 4.6729510e-2, 4.3908931e-2, 4.4626982e-2, 5.4736038e-2];

% Interpolation of {ad_bar, bd_bar, cd_bar}, and {Ad, Bd, Cd}
if latdeg <= 15
    ad_bar = ad_grid_bar(1);
    bd_bar = bd_grid_bar(1);
    cd_bar = cd_grid_bar(1);
    
    Ad = Ad_grid(1);
    Bd = Bd_grid(1);
    Cd = Cd_grid(1);
    
    aw = aw_grid(1);
    bw = bw_grid(1);
    cw = cw_grid(1);
    
elseif latdeg >= 75
    ad_bar = ad_grid_bar(end);
    bd_bar = bd_grid_bar(end);
    cd_bar = cd_grid_bar(end);
    
    Ad = Ad_grid(end);
    Bd = Bd_grid(end);
    Cd = Cd_grid(end);

    aw = aw_grid(end);
    bw = bw_grid(end);
    cw = cw_grid(end);

else
    lat_grid_lower = latdeg - mod(latdeg,15);
    lat_grid_upper = latdeg - mod(latdeg,15) + 15;
    ind_lower = lat_grid_lower / 15;
    ind_upper = lat_grid_upper / 15;
    
    ad_bar = ad_grid_bar(ind_lower)+(ad_grid_bar(ind_upper)-ad_grid_bar(ind_lower))/(lat_grid_upper-lat_grid_lower)*(latdeg-lat_grid_lower);
    bd_bar = bd_grid_bar(ind_lower)+(bd_grid_bar(ind_upper)-bd_grid_bar(ind_lower))/(lat_grid_upper-lat_grid_lower)*(latdeg-lat_grid_lower);
    cd_bar = cd_grid_bar(ind_lower)+(cd_grid_bar(ind_upper)-cd_grid_bar(ind_lower))/(lat_grid_upper-lat_grid_lower)*(latdeg-lat_grid_lower);
    
    Ad = Ad_grid(ind_lower)+(Ad_grid(ind_upper)-Ad_grid(ind_lower))/(lat_grid_upper-lat_grid_lower)*(latdeg-lat_grid_lower);
    Bd = Bd_grid(ind_lower)+(Bd_grid(ind_upper)-Bd_grid(ind_lower))/(lat_grid_upper-lat_grid_lower)*(latdeg-lat_grid_lower);
    Cd = Cd_grid(ind_lower)+(Cd_grid(ind_upper)-Cd_grid(ind_lower))/(lat_grid_upper-lat_grid_lower)*(latdeg-lat_grid_lower);    
    
    aw = aw_grid(ind_lower)+(aw_grid(ind_upper)-aw_grid(ind_lower))/(lat_grid_upper-lat_grid_lower)*(latdeg-lat_grid_lower);
    bw = bw_grid(ind_lower)+(bw_grid(ind_upper)-bw_grid(ind_lower))/(lat_grid_upper-lat_grid_lower)*(latdeg-lat_grid_lower);
    cw = cw_grid(ind_lower)+(cw_grid(ind_upper)-cw_grid(ind_lower))/(lat_grid_upper-lat_grid_lower)*(latdeg-lat_grid_lower);    
end

cosdoy = cos(2*pi*(doy-Dmin)/365.25);
ad = ad_bar - Ad*cosdoy;
bd = bd_bar - Bd*cosdoy;
cd = cd_bar - Cd*cosdoy;

fd_numr = 1+ad/(1+bd/(1+cd));
fd_denom = sin(E)+ad./(sin(E)+bd./(sin(E)+cd));
m_d1 = fd_numr./fd_denom;

ah = 2.53e-5;
bh = 5.49e-3;
ch = 1.14e-3;
fh_numr = 1+ah/(1+bh/(1+ch));
fh_denom = sin(E)+ah./(sin(E)+bh./(sin(E)+ch));
m_d2 = (1./sin(E)-fh_numr./fh_denom)*height/1e3; % to convert height into km

m_d = m_d1 + m_d2;

fw_numr = 1+aw/(1+bw/(1+cw));
fw_denom = sin(E)+aw./(sin(E)+bw./(sin(E)+cw));
m_w = fw_numr./fw_denom; 
%Height correction does not apply to the wet mapping function since the water vapor is not in hydrostatic equilibrium,
% and the height distribution of the water vapor is not expected to be predictable from the station height.