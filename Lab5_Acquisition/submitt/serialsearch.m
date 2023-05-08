% [channels] = serialsearch( signal, settings )
%
% Performs a serial search to acquire the satellites in view
%
% Inputs:
% signal......the sampled IF-data (>=2 ms)
% settings....struct containing the receiver settings
%             (check initSettings for more details)
%
% Output:
% channels....struct containing information about the presence of
%             satellites:
%             -> channels.PRN: set to 1 if satellites is found
%             -> channels.carrFreq: the carrier frequency of the found sat
%             -> channels.codePhase: the code-phase of the found sat, [0...1023)

function [channels] = serialsearch( signal, settings )

method_str = 'serial search';

% Intializes the channels
channels.PRN       = zeros(32,1);
channels.carrFreq  = zeros(32,1);
channels.codePhase = zeros(32,1);

% The number of samples per spreading code interval (or #samples/1ms)
samplesPerCode = round(settings.samplingFreq / ...
    (settings.chipFreq / settings.codeLength));

% Divide the signals into two consecutive ones (interval 1ms for each)
signal1 = signal(1 : settings.Ti*samplesPerCode);
signal2 = signal(settings.Ti*samplesPerCode+1 : 2*settings.Ti*samplesPerCode);

% Timestamp at each sample [s]
t = (0:settings.Ti*samplesPerCode-1)/settings.samplingFreq;

% Frequency vector to be search
fVector = settings.IF + (-settings.maxDoppler : settings.df : settings.maxDoppler);

% Code-phase offset vector to be searched [chip]
tauVector = 0:settings.dtau:settings.codeLength-settings.dtau;

% Initialize Cm = |\tilde{S}|^2 with fVector and tauVector for each sat.
Cm1 = zeros(length(fVector),length(tauVector));
Cm2 = zeros(length(fVector),length(tauVector));

%  figure();
%  clf;
%  maxC = 0;
%  scaleC = 1e-6;

% Search for each PRN candidate
for PRN = 1:32

    % C/A code at IF
    caCodeIF = caCode(PRN,settings);
    
    % Loop for fVector
    for fIndex = 1:length(fVector)
        
        % The Carrier for the current frequency
        sinCarr = sin(2*pi*fVector(fIndex)*t);
        cosCarr = cos(2*pi*fVector(fIndex)*t);
        
        % Loop for tauVector
        % Hint: To shift the code with tau [Tc], use shiftCode.m 
        for tauIndex = 1:length(tauVector)

             offset = tauVector(tauIndex)*settings.samplingFreq/settings.chipFreq;
             caCodeIF_new = shiftCode(caCodeIF,offset);
             Cm1(fIndex,tauIndex) = sum(signal1.*sinCarr.*caCodeIF_new)^2+sum(signal1.*cosCarr.*caCodeIF_new)^2;
             Cm2(fIndex,tauIndex) = sum(signal2.*sinCarr.*caCodeIF_new)^2+sum(signal2.*cosCarr.*caCodeIF_new)^2;
        end
    end
    
    
        [max_Cm1, index_Cm1] = max(max(Cm1));
        [max_Cm2, index_Cm2] = max(max(Cm2));
        if (max_Cm1 >= max_Cm2)
            Cm = Cm1;
        else 
            Cm = Cm2;
        
        end
    % Take Cm1 or Cm2 as the final Cm and Plot the selected Cm over tauVector and fVector
    % Hint: Check out the matlab function, 'mesh' for plotting
        
    mesh(tauVector,fVector,Cm);
    
    % Check if the current PRN is found
    % Hint: Compare the max. Cm with the second maxmimum using findSecondMax.m
    [max_Cm_1, index_fVector] = max(Cm);
    [max_Cm,index_tauVector] = max(max_Cm_1);  
    m2 = findSecondMax(Cm);
    flag = max_Cm/m2;
    if (flag > 3.5)
       
         fprintf ('satellite is %d, ratio = %d, fd = %d, tau = %d\n', PRN,flag,fVector(index_fVector(index_tauVector)) - settings.IF,tauVector(index_tauVector));
         channels.PRN(PRN,1) = 1;
         channels.carrFreq(PRN,1) = fVector(index_fVector(index_tauVector));
         channels.codePhase(PRN,1) = tauVector(index_tauVector);

       
    else 
         fprintf ('satellite %d not found, flag = %d\n', PRN,flag);
        
        
    end

    input('Hit the enter for the next satellite...');

end

% Scale plots
%  for PRN = 1:32
%      subplot(8,4,PRN);
%      zlim([0 1.05*maxC*scaleC]);
%  end
% 
%  % {
%  set(gcf, 'Position', get(0, 'Screensize'));
%  tightfig();
%  set(gcf, 'Position', get(0, 'Screensize'));
%  print('serial_search','-dpng','-r400');
%  %}

end