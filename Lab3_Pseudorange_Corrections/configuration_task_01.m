
%% General configuration

config_day = [2017 6 1]; % [year, month, day]

%config_station = 'wtzs'; % Wetzell, Bavaria, Germany       (mid lattitude)
% config_station = 'nya1'; % Nya, Northern Norway          (polar lattitude)
config_station = 'vill'; % Vilafranca, near Madrid, Spain   (mid lattitude)
%config_station = 'kour'; % Kourou, French Guiana        (near the equator)


%% Satellite related model
% Source for satellite positions and clock corrections

config_satposclk = satposclk.Broadcast;
% config_satposclk = satposclk.IGS;

%% Troposphere

% Tropospheric mapping function
%config_tropo_mapping = tropomapping.BlackAndEisner;
config_tropo_mapping = tropomapping.Niell;

% Source for the vertical delay
config_tropo_model = tropomodel.None;
%config_tropo_model = tropomodel.Collins;
%config_tropo_model = tropomodel.IGS;
%config_tropo_model = tropomodel.Estimate;

%% Ionosphere

config_height_iono = 400e3; % 400 km

% Mapping function
config_iono_mapping = ionomapping.SLM;

% Source for the ionosphere delay (slant or vertical)
config_iono_model = ionomodel.None;
%config_iono_model = ionomodel.Klobuchar;
%config_iono_model = ionomodel.GlobalMap;
%config_iono_model = ionomodel.IFCombination;
%config_iono_model = ionomodel.Estimation;

%% Minimum number of satellites


num_sat_min = 4+1; % 3 position, 1 receiver clock and at least one more
if(config_tropo_model == tropomodel.Estimate)
    num_sat_min = 4+2; % 3 position, 1 receiver clock, 1 Zenith path delay and at least one more
end
if(config_iono_model == ionomodel.Estimation)
    % Estimating the ionosphere results in adding K observations and K
    % unkowns, so it is neutral w.r.t to the redundancy.
    %
    % However, the frequency factors are not that good, so the performance
    % of the estimation usually decreases (think about the increased noise
    % for the IF combination)
    num_sat_min = num_sat_min+1; 
end

%% Compute position

compute_pos;