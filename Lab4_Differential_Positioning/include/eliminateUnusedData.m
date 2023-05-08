function dataset=eliminateUnusedData (datainput,referenceinput)
% Die Funktion buildDifferentialData eliminiert aus dem Datenset "datainput", der 
% zuvor über die Funktion "READ_GPS_DATA" erzeugt wurde,
% die in "reverenceinput", das z.B. durch "buildComparableData" erzeugt
% wurde, nicht vorkommenden Daten.
% Im zurückgegebenen "dataset" werden also, im gleichen Format wie
% "datainput" die für die Berechnung notwendigen Daten zurückgegeben

 i=0;
 datasetcounter=0;

 disp('Starte Bearbeitung...');

 % Lese die verwendeten Satelliten ein
 satellites=getSatellites(referenceinput);
 
 % Lese die verwendeten Zeitpunkte ein
 timing=getTimingData(referenceinput);

 oldiii=0;
 helpiii=0;
 
 while i< len (datainput)
    i=i+1;
    % Für den Benutzer anzeigen, dass gearbeitet wird...
    if (mod(i,len(datainput)/10)<1)
        disp([' ' num2str(i/len(datainput)*100) '%']);
    end
    
    ii=0;
    
    iii=oldiii;
    
    while (iii<len(timing))
        iii=iii+1;
        test=1;
        % Prüfen, ob der Zeitpunkt verwendet wird
        for ii=1:6
            if (timing{iii,ii}~=datainput{i,ii})
                test=0;
                break;
            end
        end
    
        % Nur wenn der Zeitpunt verwendet wird, überhaupt weitermachen
        if (test==1)
            test=0;
            
            sats=satellites{iii,7};
            for ii=1:len(sats)
            
                % Überprüfen ob der Satellit verwendet wird
                if (sats(ii)==datainput{i,7})
                
                    test=1;
                    break;
                end
            end
    
            if (test==1)
        
                % Einen neuen Datensatz erzeugen und die Daten eintragen
                datasetcounter=datasetcounter+1;
    
                for ii=1:size(datainput,2)
                    dataset{datasetcounter,ii}= datainput{i,ii};
                end
                oldiii=iii-1;
                break;
            end
        end    
    end
end 

disp('fertig.');



 function satset=getSatellites (dataSet)
    % Die Funktion getSatellites liest alle vorkommenden Satelliten aus
    % "dataSet" aus und gibt sie als einfache Liste pro Zeitpunkt zurück. "dataSet" ist
    % dabei vom Format "navinput"
    %   
    %   
 
  i=0;
  datasetcounter=0;
  
  disp(' Lese Satellitendatensätze...');
  while i<len(dataSet)
      
      i=i+1;
      
      % Einen Datensatz erzeugen und die Zeiteinträge kopieren
      datasetcounter=datasetcounter+1;
      for ii=1:6
          returnset{datasetcounter,ii}=dataSet{i,ii};
      end
      
      ii=i;      
      test=1;
      helpsetcounter=0;
      clear helpset;
      while ((ii<=len(dataSet)) && (test==1))
          % Prüfen, ob
          for iii=1:6
              if (returnset{datasetcounter,iii}~=dataSet{ii,iii})
                  test=0;
                  break;
              end
          end
          
          if (test==1)
              helpsetcounter=helpsetcounter+1;
              helpset(helpsetcounter)=dataSet{ii,7};
              ii=ii+1;
          end
      end
      returnset{datasetcounter,7}=sort(helpset);
      
      if (ii< len(dataSet))
          i=ii-1;
      else
          i=ii-1;
      end
  end
  satset=returnset;
  disp(' fertig.');
  
  
  function dataset=getTimingData (datainput)
% Die Funktion getTimingData liest aus dem Datenset "datainput", der 
% zuvor z.B. über die Funktion "buildDifferentialData" oder mit 
% "READ_GPS_DATA" erzeugt wurde, die Zeitwerte der Messungen aus. 
% Im zurückgegebenen "dataset" wird also, im gleichen Format wie
% "datainput" Felder 1-6 die Zeitinformation zurückgegeben.

% Lese jeweils einen Datensatz ein und gebe die enthaltene Zeitinformation
% zurück, eliminiere doppelte Zeiteinträge in den folgenden Zeilen

i=0;
datasetcounter=0;

disp(' Lese Zeitdatensätze ein...');

while i< len (datainput)
    i=i+1;
    
    ii=0;
    
    % Einen neuen Datensatz erzeugen und die Daten eintragen
    datasetcounter=datasetcounter+1;
    
    for ii=1:6
        dataset{datasetcounter,ii}= datainput{i,ii};
    end
    
    % Doppelte Einträge eliminieren
    test=1;
    while ((i<len(datainput)) && (test==1))
        i=i+1;
        
        % Dazu die ersten 6 Felder des momentanen Datensets mit dem durch i
        % gekennzeichneten aktuellen Eintrag von datainput vergleichen
        for ii=1:6
            if (dataset{datasetcounter,ii}~= datainput{i,ii})
                i=i-1;
                test=0;
                break;
            end
        end
    end
    
end 

disp(' fertig.');