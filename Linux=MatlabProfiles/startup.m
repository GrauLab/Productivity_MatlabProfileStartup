%% Optionally add library paths at startup:
  if(false) %OptDo: adapt paths below and switch to true.
    myLibPaths = [...
     '/mnt/mg/D/(Eigene Daten) permanent offen/(permanent offen) Matlab Analysis Tools/MIC Coding:', ...
     '/mnt/mg/D/(Eigene Daten) permanent offen/(permanent offen) Matlab Analysis Tools/MIC Coding/Basic Tools:', ...
     '/mnt/mg/D/(Eigene Daten) permanent offen/(permanent offen) Matlab Analysis Tools/MIC Coding/Export Tools:', ...
     '/mnt/mg/D/(Eigene Daten) permanent offen/(permanent offen) Matlab Analysis Tools/MIC Coding/Inline  Language:', ...
    ];
    addpath(myLibPaths);
    fprintf(' - appended library paths defined in [%s].\n', mfilename('fullpath'));
  end

%% Check for UTF8 and Config reminder (Howto force Matlab to use UTF-8 in Windows):
  if(true)
    %   - in C:\Program Files\MATLAB\R2016a\bin die lcdata.xml wie folgt editieren:
    %       - die Sektionen
    %             <encoding name="windows-1252" jvm_encoding="Cp1252">
    %               <encoding_alias name="1252"/>
    %             </encoding>
    %             <encoding name="ISO-8859-1">
    %                 <encoding_alias name="ISO8859-1"/>
    %             </encoding>
    %         auskommentieren oder löschen.
    %       - den Alias für 1252 in die UTF-8-Sektion eintragen:
    %           <encoding name="UTF-8">
    %               <encoding_alias name="utf8"/>
    %               <encoding_alias name="ISO8859-1"/>
    %               <encoding_alias name="1252"/>
    %           </encoding>
    % 		! falls die neue lcdata_utf8.xml editiert wurde, diese in lcdata.xml umbenennen (und die Platzhalter-lcdata.xml überschreiben)
    locales = feature('locale');
    if(~contains(locales.ctype,'UTF'))
      warning('locales do not seem to use UTF; do not save files with umlauts until this is corrected!');
    end
  end
  
%% Optionally change to custom library root dir:
  if(false) %OpdDo: enable after adapting the path to your needs.
    cd('/mnt/mg/D/(Eigene Daten) permanent offen/(permanent offen) Matlab Analysis Tools/');
  end
