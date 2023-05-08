function dataset=buildGraphableData (datainput,showDescription)
% Die Funktion buildGraphableData erzeugt aus "datainput" eine neue Matrix,
% die dann geplottet werden kann. Dabei ist die erste Spalte eine
% laufende Nummer, die der Sekunde der Beobachtung entspricht. Die weiteren
% Spalten entsprechen horizontal angeordnet den Daten, die in "datainput"
% vertikal angeordnet sind mit Feld [7] als Deskriptor.
% Ist "showDescription"==1 dann werden in der ersten Zeile die Werte der 
% Spalten 2-x erklärt. Die Datensätze beginnen dann also AB ZEILE 2 !!!!!!!
%

  i=0;
  datasetcounter=0;
  
  clear dataset;
  
  disp('Starte Bearbeitung...');
  
  % Falls showDescription nicht mitübergeben wird, dann auf 0 setzen
  if nargin<2
      showDescription=0;
  end
  
  % Zunächst den Startwert der Datensätze in Sekunden bestimmen
  start=calculateSeconds([datainput{1,4:6}]);
  
  % Dann den Endwert bestimmen
  ende=calculateSeconds([datainput{len(datainput),4:6}]);
  
  % Die Satelliten holen, damit ihnen eine Spalte zugeordnet werden kann
  satellites=getSatellites(datainput);
  
  % Von start bis ende alles durchlaufen
  for i=start:ende
        
        % Den berechneten Zeitpunkt eintragen
        
        dataset{i-start+1,1}= i;
  end
  
  i=0;
  
  while i<len(datainput)
      
      i=i+1;
      
      % Den Beobachtungszeitpunkt bestimmen
      vseconds=calculateSeconds([datainput{i,4:6}]);
      % Nach der Position in der Matrix suchen, an der die
      % Pseudorangedifferenz eingetragen werden soll
      for ii=1:len(satellites)
          if (len(satellites{ii})==len(datainput{i,7}))
              if (satellites{ii}==datainput{i,7})
                  satpos=ii+1;;
                  break;
              end
          end
      end
     
      % Und eintragen
      dataset{vseconds-start+1,satpos}=datainput{i,8};
        
  end  
  
%   % Leere Zellen mit dem vorherigen Wert auffüllen
%   clear helpset;
%   for i=1:len(satellites)
%       helpset(i)=0;
%   end
% 
%   i=0;
%   while i<len(dataset)
%       i=i+1;
%       for ii=2:(len(satellites)+1)
%           if (isempty(dataset{i,ii}))
%               dataset{i,ii}=helpset(ii-1);
%           end
%       end
%       for ii=1:len(satellites)
%         helpset(ii)=dataset{i,ii+1};
%       end
%   end

  if (showDescription==1)
    % In die erste Zeile noch die Beschreibung der Daten eintragen
    helpset=dataset;
    clear dataset;
  
    for i=1:len(satellites)
      dataset{1,i+1}=satellites{i};
    end
    for i=1:len(helpset)
      [dataset{i+1,:}]=helpset{i,:};
    end
  end
  
  disp('fertig.');

          

  function vseconds=calculateSeconds (dataset)
    % Die Funktion calculateSeconds errechnet aus den Zeitangaben aus
    % "dataset" (h m s) Sekundenwerte und gibt sie zurück
    %   
    %  
  
    vseconds=dataset(1)*3600+dataset(2)*60+dataset(3);
    
    
    
  function satset=getSatellites (dataSet)
    % Die Funktion getSatellites liest alle vorkommenden Satelliten aus
    % "dataSet" aus und gibt sie als einfache Liste zurück. "dataSet" ist
    % dabei vom Format "navinput"
    %   
    %   
 
  i=0;
  returnset={};
  
  while i<len(dataSet)
      
      i=i+1;
      
      ii=1;      
      test=1;
      
      while ((ii<=len(returnset)) && (test==1))
          if (len(dataSet{i,7})==len(returnset{ii}))
            if (dataSet{i,7}==returnset{ii})
                test=0;
                break;
            end
          end
        ii=ii+1;
      end
      if (test==1) 
          returnset{ii}=dataSet{i,7};
      end
  end
  satset=returnset;
  %satset=sort([returnset{:}]);

     
