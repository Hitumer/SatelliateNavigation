function dataset=computeDGPSPointer (pointerinput,diffinput)
% Die Funktion computeDGPSPointer berechnet aus den Zeigervektoren aus
% "pointerinput" (erstellt mit doPointer) und den Pseudorangedifferenzen 
% aus "diffinput" (erstellt mit buildDifferencialData), den Vektor b, der
% von einem GPS-Messger�t zum anderen zeigt.
% In der R�ckgabematrix ist der Vektor an Position 7 zu finden

disp('Starte Bearbeitung, bitte warten...');

i=0;
ii=1;

% Alle Zeitpunkte holen
timing=getTimingData(diffinput);

datasetcounter=0;

while i< len (timing)
    
    i=i+1;

    test=1;
    
    clear delta_rho;
    clear H;
    clear b_hat;
    
    iv=0;
    
    % Lese alle Datens�tze zum momentan betrachteten Zeitpunkt ein
    while (test==1) && (ii<=len(diffinput))
        
        for iii=1:6
            if (timing{i,iii}~=diffinput{ii,iii})
                test=0;
                break;
            end
        end
        
        if (test==1)
            
            iv=iv+1;
            % Lese alle Datens�tze aus "diffinput" ein und erzeuge daraus den
            % Differenzenvektor delta_rho
            delta_rho(iv)=diffinput{ii,8};

            % Lese alle Datens�tze aus "pointerinput" ein und erzeuge daraus die Matrix
            % H, die aus transponierten e-Vektoren besteht.
            
            % doPointer
            H(iv,:)=[pointerinput{ii,8:10} 1];
            
            ii=ii+1;
        end
    end
    
    % Verification of required number of satellites
    if (iv>3)
        datasetcounter=datasetcounter+1;
        delta_rho=delta_rho';
        
        % *****************************************************************
        % Implement baseline estimation b_hat using geometry matrix H 
        % and differenced pseudoranges delta_rho:
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        % *****************************************************************
        
        for iii=1:6
            dataset{datasetcounter,iii} = timing{i,iii};
        end
        dataset{datasetcounter,7} = b_hat;
    end
end



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