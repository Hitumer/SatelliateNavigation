addpath include;
addpath include/enums;

c = 299792458; % speed of light in m/s
f1 = 154.0*10.23e6; % GPS L1 frequency in Hz


[obsFile,navFile] = checkRinexFiles( config_station, config_day );

[PRN, OrbitP,alpha,beta] = parseNavigationFile( navFile );
[time,r_c,PR1,PR2] = parseObservationFile( obsFile, 'C1,C2' );

dayNumber = computeDoY(mean(time(1,:)),mean(time(2,:)));
time_of_day = mod(time(2,:), 24*3600);


if config_tropo_model == tropomodel.IGS
    [zpd, zpd_t] = getIGSTropoZenDelay(config_station, config_day(1), dayNumber);
    mask = isfinite(zpd) & isfinite(zpd_t);
    zpd = zpd(mask);
    zpd_t = zpd_t(mask);
end

if config_iono_model == ionomodel.GlobalMap
    [iono_map, iono_lat, iono_lon, iono_time] = getIonex('cod', config_day(1), dayNumber);
end

num_epochs = size(time,2);
%num_epochs = 100;
pos = NaN(num_epochs, 3);
res = cell(num_epochs,1);
Ihat = NaN(num_epochs, 32);
Ivhat = NaN(num_epochs, 1);
Tvhat = NaN(num_epochs,1);

[phi_u, lambda_u, height_u] = xyz2llh( r_c(1), r_c(2), r_c(3) );

progressbar('Epochs');
% loop over all available epochs
for epoch=1:num_epochs
    
    
    % the satellites that can be used have a non-zero entry
    if config_iono_model == ionomodel.IFCombination || config_iono_model == ionomodel.Estimation
        % We need both frequencies, only use satellites that provide both
        p = find( ~isnan(PR1(:,epoch)) & ~isnan(PR2(:,epoch)) ); 
    else
        p = find( ~isnan(PR1(:,epoch)) ); 
    end
    p = intersect( p, PRN );
    
    % Mask satellites that do not have ephemeris data available
    [eph, sat_mask] = getEphForSatsAndTime(OrbitP, PRN, p, time(2,epoch));
    p = p(sat_mask);
    
    % Skip if we have less than the minimum required satellites
    if length(p)<num_sat_min
        progressbar(epoch/num_epochs);
        continue;
    end
    
    if config_satposclk == satposclk.Broadcast
        [x_s, ~, dtSat] = getSatPos( time(:,epoch), p, PRN, OrbitP, PR1(:,epoch) );
    elseif config_satposclk == satposclk.IGS
        x_s = NaN(length(p),3);
        dtSat = NaN(length(p),1);
        
        for i=1:length(p)
            [x_s(i,:), dts] = satposclkIGS( time_of_day(epoch), config_day(1), dayNumber, p(i) );
            dtSat(i) = dts + getRelCorr(eph(i), time(2,epoch));
        end
    else
        error('Model not implemented');
    end
    
    
    % the weights after the Black+Eisner Tropospheric Mapping Function
    % (TMF), e.g. in 'Possible Weighting Schemes for GPS Carrier Phase
    % Observations in the Presence Of Multipath'
    [az,el] = lsPos( x_s, PR1(p,epoch) + dtSat*c );
    %rho_var = 1.001^2./(.002001+sin(el));
    %w = 1./rho_var;
    w = (1.0 + 10.0*exp(-el*180/pi/10.0)).^2;
    
    % tropospheric correction
    if config_tropo_mapping == tropomapping.BlackAndEisner
        [mw,md] = mappingTropoBlackEisner( el );
    elseif config_tropo_mapping == tropomapping.Niell
        [mw,md] = mappingTropoNiell( el, phi_u, dayNumber, lambda_u );
    else
        error('Model not implemented');
    end
    
    if config_tropo_model == tropomodel.Collins
        [tauw,taud] = modelTropoCollins( r_c(1:3), dayNumber );
    elseif config_tropo_model == tropomodel.IGS
        % load ZPD mat for station and day
        tau_total = modelTropoIGSZenithDelay( time(2,epoch), zpd, zpd_t );
        
        % IGS only provides one total delay. Assume 90% of it is the dry
        % component and 10% the wet component
        tauw = 0.1*tau_total;
        taud = 0.9*tau_total;
    elseif config_tropo_model == tropomodel.Estimate
        % Do not correct anything apriori
        tauw = 0;
        taud = 0;
    elseif config_tropo_model == tropomodel.None
        tauw = 0;
        taud = 0;
    end
    
    % troposphere correction
    tc  = tauw*mw + taud*md;
    Tvhat(epoch) = tauw+taud;
    
    if ~isfinite(tc)
        fprintf('Tropospheric correction unavailable, skipping epoch %d\n', epoch);
        continue;
    end
    %% ionospheric correction
    if config_iono_mapping == ionomapping.SLM
        im = mappingIonoSLM( el, height_u, config_height_iono );
    else
        error('Model not implemented');
    end
        
        
    if config_iono_model == ionomodel.Klobuchar
        [ic, ~] = modelIonoKlobuchar( time(2,epoch), alpha, beta, az, el, phi_u, lambda_u );
        [~, iv] = modelIonoKlobuchar( time(2,epoch), alpha, beta, 0, pi/2, phi_u, lambda_u );
    elseif config_iono_model == ionomodel.GlobalMap
        % compute IPP position first
        [phi_pp, lambda_pp, ~] = computeIPP(phi_u, lambda_u, el, az, config_height_iono);
        % Then obtain the TEC values one-at-a-time for each satellite
        tecu = NaN(1, length(el)+1);
        for s=1:length(el)
            %fprintf('sat %d, ', s);
            tecu(s) = modelIonoGIM(time(2,epoch), phi_pp(s), lambda_pp(s), iono_map, iono_lat, iono_lon, iono_time);
        end
        tecu(end) = modelIonoGIM(time(2,epoch), phi_u, lambda_u, iono_map, iono_lat, iono_lon, iono_time);
        
        % Finally compute the vertical delay from the TEC values
        iv = 40.3e16/(f1^2) .* tecu;
        ic = im.*iv(1:end-1);
        iv = iv(end);
    elseif config_iono_model == ionomodel.Estimation
        iv = zeros(1,length(p));
        ic = im.*iv;
    elseif config_iono_model == ionomodel.IFCombination
        iv = zeros(1,length(p));
        ic = im.*iv;
    elseif config_iono_model == ionomodel.None
        iv = zeros(1,length(p));
        ic = im.*iv;
    else
        error('Model not implemented');
    end
    
    Ihat(epoch, p) = ic;
    Ivhat(epoch) = mean(iv);
    
    
    if ~isfinite(ic)
        fprintf('Ionospheric correction unavailable, skipping epoch %d\n', epoch);
        continue;
    end
    %% Correct observations
    
    PR1_corr = PR1(p,epoch) + dtSat*c -tc.' - ic.';
    PR2_corr = PR2(p,epoch) + dtSat*c -tc.' - ic.';
    
    if config_iono_model == ionomodel.IFCombination
        PR_corr = buildIFCombination(PR1_corr, PR2_corr);
    else
        PR_corr = PR1_corr;
    end
    
    if (config_iono_model == ionomodel.Estimation) && (config_tropo_model == tropomodel.Estimate)
        % Estimate both Ionosphere and Troposhere
        [pos(epoch,:), res{epoch}, Ihat(epoch,p), Tvhat(epoch)] = estimationIonoAndTropo(PR1_corr, PR2_corr, x_s, w, mw, md);
        
        Ivhat(epoch) = lscov(im(:), Ihat(epoch,p).');
    elseif config_iono_model == ionomodel.Estimation
        % Estimate Ionosphere
        [pos(epoch,:), res{epoch}, Ihat(epoch,p)] = estimationIono(PR1_corr, PR2_corr, x_s, w);
        
        Ivhat(epoch) = lscov(im(:), Ihat(epoch,p).');
    elseif config_tropo_model == tropomodel.Estimate
        % Estimate Troposphere
        [pos(epoch,:), res{epoch}, Tvhat(epoch)] = estimationTropo(PR_corr, x_s, w, mw, md);
    else
        % Standard estimation problem
        [pos(epoch,:), res{epoch}] = estimationBasic(PR_corr, x_s, w);
    end
    
    progressbar(epoch/num_epochs);
end
progressbar(1);

% Mask epochs in which no position was estimated
pos_mask = all(~isnan(pos),2);

%% Plot result

descr = sprintf('%s, Tropo: %s %s, Iono: %s %s', config_satposclk.str(), ...
    config_tropo_model.str(), config_tropo_mapping.str(), ...
    config_iono_model.str(),  config_iono_mapping.str());

fprintf('Position results for station %s\n  with %s\n', config_station, descr);

GPSscatterplot( pos(pos_mask,:), r_c , descr);
GPSerrorplot(   pos, r_c, descr);
GPSestIonoPlot( Ihat, config_iono_model );

GPSestIonoVertPlot( Ivhat, config_iono_model, config_iono_mapping );
GPSestTropoVertPlot( Tvhat, config_tropo_model, config_tropo_mapping );