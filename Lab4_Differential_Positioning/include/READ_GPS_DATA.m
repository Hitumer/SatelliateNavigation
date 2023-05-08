function dataset = READ_GPS_DATA ( filename )
%READ_GPS_DATA ( FILENAME )
%   Liest aus einem Textfile "FILENAME", 
%   in dem RINEX-Daten gespeichert sind, GPS-Daten ein
%   und gibt diese in einem Array zur�ck
%   
%   Der Aufbau des Cell-Arrays "dataset" ist zweidimensional. Die Struktur ist wie folgend
%   dargestellt:
%   [ 1] = Jahr
%   [ 2] = Monat
%   [ 3] = Tag
%   [ 4] = Stunde
%   [ 5] = Minute
%   [ 6] = Sekunde
%   [ 7] = Satellitennummer
%   [ 8] = Pseudorange
%   [ 9] = Phasenmessung
%   [10] = Dopplerfrequenz
%   [11] = Signalst�rke (SNR-Sch�tzung)
%
%   Die Daten stammen von http://www.ngs.noaa.gov/CORS/instructions2/
%
%




 % Zun�chst die angegebene Datei �ffnen.
 % Den Filehandle zwischenspeichern in fileid
 fileid=fopen(filename,'r');

 % Gem�� RINEX-Spezifikation muss in der ersten Zeile ab Position 61
 % die Zeichenkette RINEX zu finden sein.
 % Also die erste Zeile einlesen
 workstring=fgetl(fileid);
 
 % Nach RINEX suchen
 % und abbrechen, wenn nicht an Stelle 61 gefunden wird
 if strpos('RINEX', upper(workstring)) ~= 61
     error('No RINEX-File found');
 end
 
 % Der Dateiheader ist f�r diese Anwendung nicht n�tig,
 % deshalb weiterlesen bis ab Position 61 "END OF HEADER"
 % gefunden wird
 while strpos('END OF HEADER', upper(workstring))~= 61
     workstring=fgetl(fileid);
 end
 
 % Ab der n�chsten Zeile beginnen die GPS-Datens�tze
 % Diese erste Zeile einlesen, dann erst die WHILE-Schleife beginnen
 % (entspricht einem Setup der Auslesefunktion)
 workstring=fgetl(fileid);
 
 % Da die Datens�tze erst dann g�ltig werden, wenn die Zeit auf
 % ganze Sekunden geht, den String ".0000000" ab Position 19 suchen. Die
 % Datens�tze davor k�nnen �bersprungen werden. Aber darauf achten, dass
 % das Fileende noch nicht erreicht wurde.
 while ~feof(fileid)
     
     % In dieser Schleife werden die Description-Lines ausgelesen unnd
     % ausgewertet.
     
     if strpos('.0000000', upper(workstring))~= 19
     
        % Die Anzahl der Satellitendatens�tze auslesen
        i=numberofSatellites(workstring);

        % Die Satellitendatens�tze �berspringen (enthalten noch keine
        % Informationen)
        counter=0;
        while counter<i
            
            % In dieser Schleife werden die Satellitendatens�tze eingelesen
            % und verworfen
            
            workstring=fgetl(fileid);
            counter=counter+1;
        end
     
        % Und den n�chsten Zeitpunkt einlesen
        workstring=fgetl(fileid);
     else
         % Sobald g�ltige Datens�tze gefunden werden, die Leseschleife
         % verlassen.
         break;
     end
 end
 
 % Ab diesem Zeitpunkt werden g�ltige Datens�tze ausgelesen. Diese werden
 % jetzt in dem R�ckgabearray gespeichert
 
 % Den Datensatzz�hler zur�cksetzen...
 datasetcounter=0;
 
 % ...und die Leseschleife starten. Ab jetzt werden die Daten bis zum
 % Dateiende eingelesen.
 while ~feof(fileid)
     
     % In dieser Schleife werden die Description-Lines ausgelesen unnd
     % ausgewertet.
     
     % Die Anzahl der Satellitendatens�tze auslesen
     i=numberofSatellites(workstring);
     
     % Die Satellitennummern auslesen
     satellitenumbers=getSatelliteNumbers(workstring);
     
     % Die Zeitangaben holen
     datetime=getDateTime(workstring);
     
     % Die Satellitendatens�tze einlesen
     counter=0;
     
     while counter<i
      
         % In dieser Schleife werden die Satellitendatens�tze eingelesen
         % und gespeichert
         
         % Einen Datensatz f�r den aktuellen Satelliten erzeugen
         datasetcounter=datasetcounter+1;
         satelliteset=cell(11);
         
         % Zun�chst das Datum eintragen
         for ii=1:6
             satelliteset{ii}=datetime(ii);
         end
         
         % Dann die Nummer des Satelliten hinzuf�gen
         satelliteset{7}=satellitenumbers(counter+1);
         
         % Den zugeh�rigen Navigationsdatensatz auslesen
         workstring=fgetl(fileid);
         
         % Den Navigationsdatensatz in seine Bestandteile zerlegen
         navset= getNavigationSet(workstring);
         
         % Die Navigationsdaten in den Datensatz einf�gen
         satelliteset{8}=navset(1);
         satelliteset{9}=navset(2);
         satelliteset{10}=navset(3);
         satelliteset{11}=navset(4);
         
         % Den Satellitendatensatz als R�ckgabedatensatz speichern
         for ii=1:11
            dataset{datasetcounter,ii}= satelliteset{ii};
         end
         
         counter=counter+1;
     end
     
     % Und die n�chste Description-Line einlesen
     workstring=fgetl(fileid);
    
 end
 

 % Daf�r sorgen, dass die Datei auch wieder geschlossen wird
 fclose(fileid);

 

function navset=getNavigationSet (navigationString)
% Die Funktion getNavigationSet liest den "navigationString" aus und gibt
% ein eindimensionales Array zur�ck, das wie folgt aufgebaut ist:
%   [ 1] = Pseudorange
%   [ 2] = Phasenmessung
%   [ 3] = Dopplerfrequenz
%   [ 4] = Signalst�rke (SNR-Sch�tzung)

 % Pseudorange holen
 navset(1)=str2double(navigationString(1:14));
 
 % Phasenmessung holen
 navset(2)=str2double(navigationString(16:31));

 % Dopplerfrequenz holen
 navset(3)=str2double(navigationString(33:46));
 
 % Signalst�rke holen
 navset(4)=str2double(navigationString(48:62));
 
 
 
function satellites=getSatelliteNumbers (descriptionString) 
% Die Funktion getSatelliteNumbers gibt die Satellitennummern zur�ck, die
% im "descriptionString" ab Position 33 zu finden sind. Diese Nummern ist
% der Kennzeichner "G" vorangestellt, der als Trennzeichen der Liste gelten
% kann.

 % Die Anzahl der Satelliten holen
 satcount=numberofSatellites(descriptionString);

 % Die Satellitennummern einzeln herauskopieren
 i=1;
 while i<=satcount
     % Den String ab Position 33 bis zum Ende kopieren
     helpstring=descriptionString(30+(i*3):32+(i*3));
    
     % Das "G" abschneiden und die Nummer in das R�ckgabearray speichern
     satellites(i)=str2num(helpstring(2:3));
    
     i=i+1;
 end



function datetime=getDateTime (descriptionString)
% Die Funktion getDateTime liest aus "descriptionString" Datum und Uhrzeit
% der Messung aus und gibt beide Informationen in einem eindimensionalen
% Array zur�ck, das wie folgt aufgebaut ist:
%   [ 1] = Jahr
%   [ 2] = Monat
%   [ 3] = Tag
%   [ 4] = Stunde
%   [ 5] = Minute
%   [ 6] = Sekunde

 % Jahr holen
 datetime(1)=str2num(descriptionString(2:3));

 % Monat holen
 datetime(2)=str2num(descriptionString(5:6));

 % Tag holen
 datetime(3)=str2num(descriptionString(8:9)); 

 % Stunde holen
 datetime(4)=str2num(descriptionString(11:12));

 % Minute holen
 datetime(5)=str2num(descriptionString(14:15));

 % Sekunde holen (Hier nur Vorkommastellen, weil ja schon darauf getestet
 % wurde, dass die Nachkommastellen 0 sind)
 datetime(6)=str2num(descriptionString(17:18));



function count=numberofSatellites (descriptionString)
% Die Funktion numberofSatellites liest den "descriptionString" an den
% Positionen 31 und 32 aus und bestimmt daraus die Anzahl der gelesenen
% Satellitendatens�tze (die Anzahl Satelliten, die zur Positionsbestimmung
% vorhanden war)

 % 2 Zeichen von Position 31 ab lesen,
 helpstring=strcat(descriptionString(31),descriptionString(32));
 
 % in eine Zahl umwandeln und zur�ckgeben
 count=str2num(helpstring);

 
 
function position=strpos (searchedString, testString)
% Die Funktion strpos gibt die Position des gesuchten Strings
% "searchedString" innerhalb von "testString" zur�ck. Sollte der gesuchte
% String in "testString" nicht auftauchen, gibt die Funktion 0 zur�ck

 % Die Matlab-Funktion findstr zur Suche des Strings searchedString
 % verwenden
 
 i = findstr(searchedString, testString);
 
 % Testen ob i eine Nullmatrix ist, der searchedString also nicht in
 % testString vorkommt
 if length (i)==0
     position=0;
 else
     position=i;
 end
 