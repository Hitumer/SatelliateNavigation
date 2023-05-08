function dataset=buildDifferentialData (datainput)
% Die Funktion buildDifferentialData liest aus dem Datenset "datainput", der 
% zuvor über die Funktion "getComparableData" erzeugt wurde,
% die zusammengehörenden Satellitendaten aus und zieht die Pseudoranges
% voneinander ab.
% Im zurückgegebenen "dataset" wird also, im gleichen Format wie
% "datainput" die Differenz der Pseudoranges der beiden über
% "getComparableData" eingelesenen Satellitendaten zurückgegeben. Der Rest
% der Matrix besteht aus den Einträgen der zweiten Zeile des eingelesenen
% Datensets "datainput".

% Lese jeweils zwei Datensätze ein und ziehe Pseudorange des ersten
% Datensatzes von der Pseudorange des zweiten Datensatzes ab.
% Die Pseudorange ist im Matrixfeld [8] kodiert.

i=0;
datasetcounter=0;

disp('Starte Bearbeitung...');

while i< length (datainput)
    i=i+2;
    
    ii=0;
    
    % Einen neuen Datensatz erzeugen und die Daten eintragen
    datasetcounter=datasetcounter+1;
    
    for ii=1:11
        dataset{datasetcounter,ii}= datainput{i,ii};
    end
    
    % Pseudoranges voneinander abziehen
    dataset{datasetcounter,8}=datainput{i,8}-datainput{i-1,8};
    
end 

disp('fertig.');