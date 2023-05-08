function data=len (datainput)
    % Die Funktion len gibt die Anzahl der Zeilen einer Matrix zurück

    
    i=size(datainput);
    
    if (i(1)~=1)
        data=i(1);
    else
        data=length(datainput);
    end
    
