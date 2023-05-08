function dataset=computeDoubleDifferences (datainput)
% Die Funktion computeDoubleDifferences berechnet aus den
% Differenzenvektoren "datainput", die zuvor mit buildDifferentialData
% erzeugt wurden, zusätzliche Differenzen zwischen allen Satelliten zu
% einem Zeitpunkt. Beispielsweise also Differenz der Differenzdaten des
% Satelliten 3 und der Differenzdaten des Satelliten 22.
%
% In Spalte [7] wird dabei als Zeichenkette die Differenzenoperation
% "beschrieben" ('3-22'). Das Ergebnis steht in Spalte [8].

disp('Starte Bearbeitung, bitte warten...');

i=0;
ii=1;

% Alle Zeitpunkte holen
timing=getTimingData(datainput);

datasetcounter=0;

while i< len (timing)
    
    i=i+1;
    test=1;
    
    clear satdiffs;
    
    iv=0;
    
    % Lese alle Datensätze zum momentan betrachteten Zeitpunkt ein
    while (test==1) && (ii<=len(datainput))
        
        for iii=1:6
            if (timing{i,iii}~=datainput{ii,iii})
                test=0;
                break;
            end
        end
        
        if (test==1)
            
            iv=iv+1;
            
            % Lese alle Datensätze aus "datainput" ein und erzeuge daraus den
            % Differenzenvektor satdiffs
            satdiffs(iv,:)={datainput{ii,7:8}};
            
            ii=ii+1;
        end
    end

    iv=0;

    % Die Differenzenvektoren bilden
    while (iv< len (satdiffs))
        iv=iv+1;
        
        v=iv;
        while (v+1<len (satdiffs))
            v=v+1;
            
            % Einen neuen Datensatz erzeugen und die Zeitwerte eintragen
            datasetcounter=datasetcounter+1;
            for vi=1:6
                dataset{datasetcounter,vi}=timing{i,vi};
            end
            
            % Die Differenzen "erklären" (Feld 7), bilden und eintragen
            % (Feld 8)
            dataset{datasetcounter,7}=[num2str(satdiffs{iv,1}) '-' num2str(satdiffs{v,1})];
            dataset{datasetcounter,8}=satdiffs{iv,2}-satdiffs{v,2};
        end
        
    end
end

disp('fertig.');


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