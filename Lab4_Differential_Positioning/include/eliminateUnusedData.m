function dataset=eliminateUnusedData (datainput,referenceinput)
% Die Funktion buildDifferentialData eliminiert aus dem Datenset "datainput", der 
% zuvor �ber die Funktion "READ_GPS_DATA" erzeugt wurde,
% die in "reverenceinput", das z.B. durch "buildComparableData" erzeugt
% wurde, nicht vorkommenden Daten.
% Im zur�ckgegebenen "dataset" werden also, im gleichen Format wie
% "datainput" die f�r die Berechnung notwendigen Daten zur�ckgegeben

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
    % F�r den Benutzer anzeigen, dass gearbeitet wird...
    if (mod(i,len(datainput)/10)<1)
        disp([' ' num2str(i/len(datainput)*100) '%']);
    end
    
    ii=0;
    
    iii=oldiii;
    
    while (iii<len(timing))
        iii=iii+1;
        test=1;
        % Pr�fen, ob der Zeitpunkt verwendet wird
        for ii=1:6
            if (timing{iii,ii}~=datainput{i,ii})
                test=0;
                break;
            end
        end
    
        % Nur wenn der Zeitpunt verwendet wird, �berhaupt weitermachen
        if (test==1)
            test=0;
            
            sats=satellites{iii,7};
            for ii=1:len(sats)
            
                % �berpr�fen ob der Satellit verwendet wird
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
    % "dataSet" aus und gibt sie als einfache Liste pro Zeitpunkt zur�ck. "dataSet" ist
    % dabei vom Format "navinput"
    %   
    %   
 
  i=0;
  datasetcounter=0;
  
  disp(' Lese Satellitendatens�tze...');
  while i<len(dataSet)
      
      i=i+1;
      
      % Einen Datensatz erzeugen und die Zeiteintr�ge kopieren
      datasetcounter=datasetcounter+1;
      for ii=1:6
          returnset{datasetcounter,ii}=dataSet{i,ii};
      end
      
      ii=i;      
      test=1;
      helpsetcounter=0;
      clear helpset;
      while ((ii<=len(dataSet)) && (test==1))
          % Pr�fen, ob
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
% zuvor z.B. �ber die Funktion "buildDifferentialData" oder mit 
% "READ_GPS_DATA" erzeugt wurde, die Zeitwerte der Messungen aus. 
% Im zur�ckgegebenen "dataset" wird also, im gleichen Format wie
% "datainput" Felder 1-6 die Zeitinformation zur�ckgegeben.

% Lese jeweils einen Datensatz ein und gebe die enthaltene Zeitinformation
% zur�ck, eliminiere doppelte Zeiteintr�ge in den folgenden Zeilen

i=0;
datasetcounter=0;

disp(' Lese Zeitdatens�tze ein...');

while i< len (datainput)
    i=i+1;
    
    ii=0;
    
    % Einen neuen Datensatz erzeugen und die Daten eintragen
    datasetcounter=datasetcounter+1;
    
    for ii=1:6
        dataset{datasetcounter,ii}= datainput{i,ii};
    end
    
    % Doppelte Eintr�ge eliminieren
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