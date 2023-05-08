function [ephs_out, sat_mask] = getEphForSatsAndTime(OrbitP, PRN, sats, gps_sec)


num_sats = length(sats);

sat_mask = false(num_sats,1);
ephs(num_sats) = OrbitP(1);

for i=1:num_sats
    sat = sats(i);
    
    eph_sat = OrbitP(PRN == sat);
    eph_sat_past = eph_sat((gps_sec(:)-vertcat(eph_sat.t_oe))>=0);
    
    if length(eph_sat_past)>1
        [~, indx] = min(gps_sec(:)-vertcat(eph_sat_past.t_oe));
        eph_tmp = eph_sat_past(indx);
    else
        eph_tmp = eph_sat_past;
    end
    
    if ~isempty(eph_tmp)
        sat_mask(i) = true;
        ephs(i) = eph_tmp;
    end
end

ephs_out = ephs(sat_mask);
end
