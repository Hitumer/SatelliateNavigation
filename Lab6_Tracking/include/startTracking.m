% startTracking( fid, acqResults, settings )
% 
% starts the tracking for a IF-datefile opened with file pointer fid. It
% uses the results of a beforehand done acquisition. The actual tracking is
% done in the function 'trackPRN(...)', which is called for each found PRN. 
% 
% fid............... file pointer for the IF-datafile
% acqResults........ the results of the acquisition process
% settings.......... structure containing the settings of the receiver
% 
function startTracking( fid, acqResults, settings )

availPRN = find(acqResults.PRN==1);
for p=1:length(availPRN)
    
    PRN = availPRN(p);
    codePhase = acqResults.codePhase(PRN);
    carrFreq  = acqResults.carrFreq(PRN);
    
    [Ip,Qp,f_carr,f_code,codeDiscr] = trackPRN( fid, PRN, codePhase, carrFreq, settings );
    t0 = findFirstBitTransition( Ip );
    N = floor( (length(Ip)-t0)/20 );
    bits = zeros(1,N);
    for k=1:N
        bits(k) = detectBit( Ip(t0+(k-1)*20+(1:20)) );
    end
    
    % Plots the I- and Q-Components
    figure(1);
    subplot(2,2,1:2);
    t = (0:length(Ip)-1)*1e-3;
    plot(t,Ip,'r',t,Qp,'b');
    xlabel('Time [s]');
    legend('Inphase','Quadrature');
    % find the lower and upper limits for the plot
    minIp = fix(min(Ip)/1e3);
    l1 = (minIp-1.8)*1e3;
    l2 = (fix(max(Ip)/1e3)+1)*1e3;
    ylim([l1 l2]);
    xlim([t(1) t(end)]);
    % plot a dotted line at each bit transition
    line([t(t0) t(t0)],[l1 l2],'LineStyle',':','Color','k');
    for k=1:N
        if bits(k) >= 0
            bitVal = '+';
        else
            bitVal = '-';
        end
        % add a text for the sign of the bits
        text( t( t0+9+(k-1)*20 ), (minIp-1.1)*1e3, bitVal );
        line([t(t0+k*20) t(t0+k*20)],[l1 l2],'LineStyle',':','Color','k');
    end
    
    % Plots the Doppler frequency
    figure(1);
    subplot(2,2,3);
    plot(t,f_carr-settings.IF);
    xlim([t(1) t(end)]);
    xlabel('Time [s]');
    ylabel('Doppler Frequency [Hz]');
    
    % Plots the Code frequency
    figure(1);
    subplot(2,2,4);
%     plot(t,f_code-1.023e6);
    plot(t,codeDiscr);
    xlim([t(1) t(end)]);
    ylim([-2 2]);
    xlabel('Time [s]');
    %     ylabel('Code Frequency Offset [Chips/s]');
    ylabel('Code Discriminator [Chips]');

    % Plots the Constelllation-diagram
    figure(2);
    % Colormap (first=blue, last=rad)
    cm=colormap();
    cmindex = ([1:size(cm,1)]-1)/size(cm,1);
    colPlot = zeros(length(Ip),3);
    for k=1:length(Ip)
        colPlot(k,:) = interp1(cmindex,cm,(k-1)/length(Ip));
    end
    scatter( Ip, Qp, [], colPlot, '.' );
    xlabel('Inphase (or Real)');
    ylabel('Quadrature (or Imaginary)');
    title('Constellation Diagram');
    hcb = colorbar('YTickLabel',{'First','Last'});
    set(hcb,'YTickMode','manual');
    set(hcb,'YTick',[0 1]);

    input('Hit ENTER to continue with the next PRN ');
end
