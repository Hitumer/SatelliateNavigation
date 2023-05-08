function dataset=getComparableData (dataset1,dataset2)
% Die Funktion getComparableData liest aus den beiden Datensets "dataset1"
% und "dataset2", die zuvor über die Funktion "READ_GPS_DATA" erzeugt wurden,
% die einzelnen Satellitendaten aus und gibt nur diejenigen Datensätze
% zurück, die zum gleichen Zeitpunkt mit dem gleichen Satelliten gemacht
% wurden.
% Im zurückgegebenen "dataset" gehören, im gleichen Format wie
% "dataset1" und "dataset2", jeweils 2 aufeinanderfolgende Datensätze
% zusammen. Zeile 1 enthält die Einträge für den betrachteten Satelliten
% aus "dataset1", die darauffolgende Zeile die entsprechenden Daten aus
% "dataset2"

% Lese alle Datensätze aus "dataset1" und suche nach in den ersten 7
% Feldern identischen Einträgen in "dataset2"

i=0;
oldii=0;
datasetcounter=0;

dataset=[];

disp('Starte Bearbeitung, bitte warten...');

while i< len (dataset1)
    i=i+1;
    
    % Davon ausgehen, dass die Datensätze zeitlich ansteigen, deswegen nach
    % einem erfolgreichen Durchlauf beim alten Vergleichsdatensatz
    % wiederanfangen.
    ii=oldii;
    
    while ii< len (dataset2)
        ii=ii+1;
        test=1;
        iii=0;
        
        % Die ersten 7 Matrixeinträge vergleichen
        while ((iii<7) && (test==1))
            iii=iii+1;
            
            % Wenn ein Unterschied gefunden wird, dann abbrechen
            if dataset1{i,iii}~=dataset2{ii,iii}
                
                test=0;
                break;
            end
        end
        
        % Wenn Test==1 dann sind beide Einträge identisch und ein Eintrag in
        % das Rückgabe dataset kann erfolgen
        
        if test==1
            % Einen Datensatz erzeugen
            datasetcounter=datasetcounter+1;
            
            for iii=1:11
             dataset{datasetcounter,iii}= dataset1{i,iii};
             dataset{datasetcounter+1,iii}= dataset2{ii,iii};
            end
            
            % Da zwei Einträge geschrieben werden, den datasetcounter
            % nochmal um 1 erhöhen
            datasetcounter=datasetcounter+1;  
            
            oldii=ii;
            break;
        end
    end
end

disp('fertig.');