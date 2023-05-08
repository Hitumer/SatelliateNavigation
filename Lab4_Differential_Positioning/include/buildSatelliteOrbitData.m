function dataset=buildSatelliteOrbitData (navinput,ephinput)
% Die Funktion buildSatelliteOrbitData liest aus dem Datenset "navinput", 
% der zuvor über die Funktion "getDifferentialData" erzeugt wurde,
% die Satellitendaten aus und erzeugt anschließend unter
% zuhilfename des mit der Funktion "get_eph" eingelesenen Datensets
% "ephinput" die Satellitenpositionen zu den jeweiligen Zeitpunkten.
% Im zurückgegebenen "dataset" wird also, im folgenden Format die Position
% der GPS-Satelliten festgehalten:
%
%   [ 1] = Jahr
%   [ 2] = Monat
%   [ 3] = Tag
%   [ 4] = Stunde
%   [ 5] = Minute
%   [ 6] = Sekunde
%   [ 7] = Satellitennummer
%   [ 8] = Satellit X  (km)
%   [ 9] = Satellit Y  (km)
%   [10] = Satellit Z  (km)
%

  i=0;
  datasetcounter=0;
  
  disp('Starte Bearbeitung...');

  while i< len (navinput)
      i=i+1;
    
        % Einen neuen Datensatz erzeugen
        datasetcounter=datasetcounter+1;
        
        % Den berechneten Zeitpunkt und Satelliten eintragen
        for iii=1:7
            dataset{datasetcounter,iii}= navinput{i,iii};
        end
        
        vseconds=calculateSeconds([dataset{datasetcounter,4:6}]);
        
        % Die Satellitennummer ergänzen
        satellitenumber=navinput{i,7};
    
        % Die Satellitenposition berechnen
        satellitePositions=[satpos(vseconds,ephinput(:,satellitenumber))]';
        for iii=8:10
            dataset{datasetcounter,iii}=satellitePositions(iii-7);
        end
  end  
  disp('fertig.');

          

  function vseconds=calculateSeconds (dataset)
    % Die Funktion calculateSeconds errechnet aus den Zeitangaben aus
    % "dataset" (h m s) Sekundenwerte und gibt sie zurück
    %   
    %  
  
    vseconds=dataset(1)*3600+dataset(2)*60+dataset(3);

     
