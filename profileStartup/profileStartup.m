%ABSTRACT
%  Allows specification of a profile mnemonic at Matlab startup and appends it to window
%  titles of the desktop and the command window.
%  Also appends the profile mnemonic to Matlab's application ID so that windows from 
%  different Matlab profiles are grouped in different icons on the Windows taskbar.
%  Combined with different settings/profile directories (see below) this is very useful when 
%  working concurrently with multiple Matlab sessions (you can have different sets of opened
%  m files and/or figures in the editors of each profile, configure different colors, etc.)
%HINTS:
% - Howto write a startup batch file:
%    In order to launch Matlab with different profiles, the profile directory (prefsdir)
%    must be specified before startup via the environment variable MATLAB_PREFDIR. Example:
%    - Windows batch file:
%      @ECHO OFF
%      set MATLAB_PREFDIR=C:\Users\MG\AppData\Roaming\MathWorks\MATLAB\primary
%      start "MATLAB, primary profile" "C:\Program Files\MATLAB\R2018b\bin\matlab.exe" -r "profileStartup('primary profile','grayed blue->cyan');"
%    - Ubuntu shell script:
%      export MATLAB_PREFDIR="/path/to/extracted/ZIP/primary"; #contains matlab.settings
%      export STARTUP_PATH="/path/to/extracted/ZIP"; #contains startup.m
%      export INITIAL_COMMAND="profileStartup('primary profile','grayed blue->cyan');";
%      /usr/local/bin/matlab -desktop -sd "$STARTUP_PATH" -r "$INITIAL_COMMAND";
%DEV NOTE: how to (re)create the prototype and thunk file for needed calls to the system functions on Windows:
%   headerFileName = fullfile(pwd,'ShObjIdl.h');
%   loadlibrary(fullfile(getenv('SystemRoot'),'System32','shell32.dll'),headerFileName,'mfilename','shell32_AppID_prototype')
%   - then open the generated shell32_AppID_prototype.m and keep only the functions of interest (SetCurrentProcessExplicitAppUserModelID and GetCurrentProcessExplicitAppUserModelID and nothing else for fast library loading.
%   loadlibrary(fullfile(getenv('SystemRoot'),'System32','shell32.dll'),@shell32_AppID_prototype); %use the slim prototype for performance (only AppID functions extracted).
%   With respect to setAppID.cpp, use mex('setAppID.cpp','shlwapi.lib','Propsys.lib') to compile and link the app ID functions statically.
%REQUIREMENTS
%  Tested on Windows 10 x64 (works since Windows 7 x64) and on Linux (Ubuntu).
%AUTHOR
%  Michael Grau, October 2013.

function profileStartup(sProfileMnemonicLocal, profileColor)
  %% Publish profile mnemonic as global variable:
    global sProfileMnemonic;
    if(nargin>=1 && ~isempty(sProfileMnemonicLocal))
      sProfileMnemonic = sProfileMnemonicLocal;
    end    
    assert(~isempty(sProfileMnemonic), ' ! profileStartup: sProfileMnemonic was empty; cannot continue.');
    fprintf(' - profileStartup: Matlab started using profile "%s" [%s]\n', sProfileMnemonic, prefdir); drawnow;
  %% Append profile mnemonic to window title and keep them persistent:
    global hUpdateWindowTitleWithProfileNameTimer;
    if(~isempty(hUpdateWindowTitleWithProfileNameTimer))
      stop(hUpdateWindowTitleWithProfileNameTimer);
    end
    hUpdateWindowTitleWithProfileNameTimer = timer('Name','MIC Keep Matlab Profile mnemonic in window title' ...
      ...,'TimerFcn', @(myTimerObj, thisEvent) ilx(@appendProfileMnemonicToWindowTitle) ...
      ,'TimerFcn', @(myTimerObj, thisEvent) appendProfileMnemonicToWindowTitle() ...
      ,'BusyMode', 'drop' ...
      ,'ExecutionMode', 'fixedSpacing' ...
      ,'StartDelay', 0.1 ...
      ,'Period', 2.5 ... %repeat necessary to make profile title persistent, even if the user docks/undocks the command window, for example.
    );
      start(hUpdateWindowTitleWithProfileNameTimer);
  %% Windows only: AppID logic for parallel profiles with separate Windows taskbar icon groups:
    if(ispc)
      %Load Shell32 Library:
        bLibLoaded = libisloaded('shell32'); %Shell32 is not loaded, but shell32 is??
        if(~bLibLoaded) try
          %loadlibrary(fullfile(getenv('SystemRoot'),'System32','shell32.dll'), @shell32_AppID_prototype); %use the slim prototype for performance (only AppID functions extracted).
          loadlibrary(fullfile(getenv('SystemRoot'),'System32','shell32.dll'), @shell32_AppID_prototype_Win10SDKv201804_onlyNeeded); %use the slim prototype for performance (only AppID functions extracted).
          bLibLoaded = true;
          
          %libfunctions('shell32','-full');
          %libfunctionsview('shell32');
          %unloadlibrary('shell32')
          
          %NOTE: howto (re)create the prototype and thunk file:
            % %headerFileName = fullfile(pwd,'ShObjIdl.h');
            % cd('D:\(Eigene Daten) permanent offen\(permanent offen) Matlab Analysis Tools\MIC Coding\Basic Tools\profileStartup');
            % headerFileName = fullfile(pwd,'ShObjIdl_core_Win10SDK201810.h');
            % loadlibrary(fullfile(getenv('SystemRoot'),'System32','shell32.dll'),headerFileName, 'mfilename','shell32_AppID_prototype_Win10SDKv201804')
            % - then open the generated shell32_AppID_prototype.m and keep only the functions of interest: 
            %   <- SetCurrentProcessExplicitAppUserModelID and 
            %   <- GetCurrentProcessExplicitAppUserModelID and 
            %   <- nothing else for fast library loading.
            % %loadlibrary(fullfile(getenv('SystemRoot'),'System32','shell32.dll'),@shell32_AppID_prototype);
            % loadlibrary(fullfile(getenv('SystemRoot'),'System32','shell32.dll'),@shell32_AppID_prototype_Win10SDKv201804_onlyNeeded);
            %   <- use the slim prototype for performance (only AppID functions extracted).
            % unloadlibrary('shell32')
        catch ex
          warning(' ! profileStartup: Could not load Shell32.dll => SKIPPING AppID configuration\n<-error details: %s', ex.message);
        end; end
      %Append profile mnemonic to AppID:
        if(bLibLoaded)
          %Set process AppID (that will be applied to all new opened windows like figures)
            if(true)
              %Read out current AppID:
                csPrealloc = libpointer('voidPtr',[int8(repmat(' ',1,128)),0]);
                %calllib('Shell32','GetCurrentProcessExplicitAppUserModelID',csPrealloc);
                calllib('shell32','GetCurrentProcessExplicitAppUserModelID',csPrealloc);
                sAppID = wchar2str(get(csPrealloc,'Value'));
                %fprintf(' - profileStartup: previous AppID: %s\n', sAppID);
              %Append profile name to AppID:
                sToAppend = ['.', string2fieldname(sProfileMnemonic)];
                sAppID = strrep(sAppID,sToAppend,''); %do not append multiple times.
                sAppID = [sAppID, sToAppend];
              %Set new AppID:
                psAppID = libpointer('voidPtr',[int8(str2wchar(sAppID)),0,0]); %terminate wchar with [0 0].
                %[status,wcharAppID] = calllib('Shell32','SetCurrentProcessExplicitAppUserModelID',psAppID);
                [status,wcharAppID] = calllib('shell32','SetCurrentProcessExplicitAppUserModelID',psAppID);
                if(status~=0) warning('SetCurrentProcessExplicitAppUserModelID unsuccessful.'); end
                newAppID = wchar2str(wcharAppID);
                fprintf(' - profileStartup: profile-specific AppID: %s\n', newAppID); drawnow;
              %unneeded/Keep AppID persistent via a timer:
                if(false)
                  start(timer('Name','MIC keep profile-specific AppID' ...
                    ,'TimerFcn', @(myTimerObj, thisEvent) {
                        ilx(@calllib,'Shell32','SetCurrentProcessExplicitAppUserModelID',psAppID);
                      } ...
                    ,'ExecutionMode', 'fixedSpacing' ...
                    ,'StartDelay', 7 ...
                    ,'Period', 7 ... %repeat to make profile title persistent, even if the user docks/undocks the command window, for example.
                  ));
                end
            end
          %Update AppID of all already opened windows to match new process AppID and update the windows (especially the Matlab desktop window):
            bDebug = false;
            setAppID(newAppID, bDebug);
        end  
    end
  %% Apply profile color:
    if(nargin<2)
      warning('profileStartup: no profile color specified; using hardcoded profile color.');
      %profileColor = [.85 .871 .91];
      profileColor = recommendedProfileColors('grayed green->cyan');
    elseif(ischar(profileColor)) %support for predefined color names
      profileColor = recommendedProfileColors(profileColor);
      [~,availableColorNames] = recommendedProfileColors('');
      if(isempty(profileColor))
        warning('profileColor must be [R G B] or one of the following names: %s=>defaulting to "grayed green->cyan"', evalc('availableColorNames'));
        profileColor = recommendedProfileColors('grayed green->cyan');
      end
    end
    fprintf(' - profileStartup: applying profile color...\n', prefdir); drawnow;
    setProfileBackgroundColor(profileColor);
  %% Check that we use an UTF locale and warn otherwise:
    localeInfo = feature('locale');
    if(~strcmp(localeInfo.encoding,'UTF-8'))
      warning('feature(''locale'') shows that the encoding is "%s", not UTF-8, i.e. umlauts and such signs might become PERMANENTLY CORRUPTED when saving m files with this Matlab configuration. To correct this problem, edit the lcdata.xml file (see in-code comments for details).', localeInfo.encoding);
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
    end
  %% notify user when finished loading:
    fprintf(' - profileStartup: Matlab ready.\n', prefdir);  
    fprintf('#########################################################################################################################################################\n', prefdir);  
    %start(timer('Name','MIC Startup triple beep' ...
    %  ,'TimerFcn', @(myTimerObj, thisEvent) {ilx(@beep); ilx(@pause,0.2); ilx(@beep); ilx(@pause,0.2); ilx(@beep)} ...
    %  ,'ExecutionMode', 'singleShot' ...
    %  ,'StartDelay', 7 ...
    %));
end

%% Worker Functions:
  function appendProfileMnemonicToWindowTitle()
    %used source from: Yair Altman (http://stackoverflow.com/questions/1924286/is-there-a-way-to-change-the-title-of-the-matlab-command-window)
    global sProfileMnemonic;
    jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;
      %jDesktop.getMainFrame.setTitle(ilv(...
      %  char(jDesktop.getMainFrame.getTitle()),[' (',sProfileMnemonic,')']...
      % ,@(currentTitle,profilePostfix)[strrep(currentTitle,profilePostfix,''),profilePostfix]...
      %));
      jDesktop.getMainFrame.setTitle(...
        [strrep(char(jDesktop.getMainFrame.getTitle()),[' (',sProfileMnemonic,')'],''), ' (',sProfileMnemonic,')']...
      );
    cmdWin = jDesktop.getClient('Command Window');
      %cmdWin.getTopLevelAncestor.setTitle(ilv(...
      %  char(cmdWin.getTopLevelAncestor.getTitle()), [' (',sProfileMnemonic,')']...
      % ,@(currentTitle,profilePostfix)[strrep(currentTitle,profilePostfix,''),profilePostfix]...
      %));
      cmdWin.getTopLevelAncestor.setTitle(...
        [strrep(char(cmdWin.getTopLevelAncestor.getTitle()), [' (',sProfileMnemonic,')'], ''), ' (',sProfileMnemonic,')'] ...
      );
  end
  function setProfileBackgroundColor(profileColor)
    %Declare variables:
      global jPreviouslyAppliedBGColor;
    try
      %Get link to Desktop:
        jDesktop = com.mathworks.mde.desk.MLDesktop.getInstance;        
      %Define bg color to be replaced:
        jDefaultBGColor = jDesktop.getMainFrame.getBackground;
      %Get the new BG color:
        rgb = profileColor;
        if(ischar(rgb)) rgb = eval(rgb); end
        assert(isnumeric(rgb) && length(rgb)==3 && all(rgb>=0 & rgb<=1), 'profileColor must bei a [r g b] with r,g,b in [0,1].');
        rgb = num2cell(rgb);
        jProfileColor = java.awt.Color(rgb{:});
      %Replace BG colors in desktop window:
        replaceBackgroundColors(...
          jDesktop.getMainFrame.getComponent(0)...
         ,[{jDefaultBGColor},iif(~isempty(jPreviouslyAppliedBGColor),{jPreviouslyAppliedBGColor},{})], jProfileColor ...
         ,50 ...
         ,{'toolstrip','com.mathworks.mwswing.MJPanel'}...  %,'status' <-Note: need to exclude the statusbar since Matlab draws it seperately for every (new) tab in the editor.
         ...,true ...
        ); 
      %Replace BG colors in command window:
        cmdWin = jDesktop.getClient('Command Window');
        replaceBackgroundColors(...
          cmdWin.getParent.getParent.getParent.getParent...
         ,[{jDefaultBGColor},iif(~isempty(jPreviouslyAppliedBGColor),{jPreviouslyAppliedBGColor},{})], jProfileColor ...
         ,20, {'com.mathworks.mwswing.MJScrollPane'} ...
         ...,true ...
        ); 
        jPreviouslyAppliedBGColor = jProfileColor; %remember for later color changes.
    catch ex
      warning('profileStartup: Could not apply profile color; details: %s', ex.message);
    end
  end  
  function [visited, queue] = replaceBackgroundColors(root, jBGColorsToReplace, jNewBGColor, maxLevel, sExcludes, bDebug)
    visited = {};
    queue = {root};
    if(nargin<4) maxLevel=50; end
    if(nargin<5) sExcludes={}; end
    if(nargin<6) bDebug=false; end
    sExcludes = cellfun(@lower,sExcludes,'UniformOutput',false);
    nLevel=0;
    while(~isempty(queue) && nLevel<=maxLevel) nLevel=nLevel+1;
      %Pop first element i queue:
        jh = queue{1};
        queue = queue(2:end);
      %Skipping logic:
        bSkip = any(cellfun(@(s)contains(lower(char(jh.toString())),s), sExcludes));
          if(bSkip && bDebug) fprintf('- SKIPPING %s\n', char(jh.toString())); end
          if(bSkip) continue; end
      %Process bg color:
        try
          currentBG = jh.getBackground;
          bShouldBeReplaced = false;
            bShouldBeReplaced = bShouldBeReplaced || (currentBG.getRed==0 && currentBG.getGreen==0 && currentBG.getBlue==0); %if the current BG is not set.
            for rci=1:length(jBGColorsToReplace) %if the current BG matches one of the replace colors:
              bShouldBeReplaced = bShouldBeReplaced || (jBGColorsToReplace{rci}.getRed==currentBG.getRed && jBGColorsToReplace{rci}.getGreen==currentBG.getGreen && jBGColorsToReplace{rci}.getBlue==currentBG.getBlue);
            end
          bAlreadyOnTargetColor = jNewBGColor.getRed==currentBG.getRed && jNewBGColor.getGreen==currentBG.getGreen && jNewBGColor.getBlue==currentBG.getBlue;
% bShouldBeReplaced = true;
          if(bShouldBeReplaced && ~bAlreadyOnTargetColor)
            jh.setBackground(jNewBGColor);
            if(bDebug)
              fprintf('<-updated background color from %s for: %s\n', char(currentBG.toString()), char(jh.toString())); 
            end
          end
          jh.repaint(); %also repaint transparent children to match their parents' bg colors.
        catch ex
          warning('<-replaceBackgroundColor: could not update background color for: %s\n  <- reason: %s\n', char(jh.toString()), ex.message);
        end
      %process children:
        children = {};
        if(~isempty(jh))
          try
            children = jh.getComponents;
            children = num2cell(children);
          catch ex
            warning('<-replaceBackgroundColor: could not add children for %s', jh.toString);
          end
        end
        for ci=1:length(children)
          if(~any(cellfun(@(jh)jh==children(ci),visited)))
            queue = [queue;children(ci)];
            visited = [visited;children(ci)];
          end
        end
    end
  end

%% Helper Functions:
  function sA = wchar2str(sW)
    endpos = min(strfind(sW,char([0,0,0])));
    if(isempty(endpos)) endpos = min(strfind(sW,char([0,0]))); end
    sW = sW(1:endpos);
    sA = char(sW(1:2:end));
  end
  function sW = str2wchar(sA)
    sW = [sA; zeros(size(sA))];
    sW = sW(:)';
  end
  function [color,colorNames]=recommendedProfileColors(colorName)
    colorNames = {
      'vivid blue->cyan'
      'vivid blue->magenta'
      'vivid green->yellow'
      'vivid green->cyan'
      'vivid red->yellow'
      'vivid red->magenta'
      'grayed blue->cyan'
      'grayed blue->magenta'
      'grayed green->yellow'
      'grayed green->cyan'
      'grayed red->yellow'
      'grayed red->magenta'
    };      
    CM = [
      [.85 .91 .97] %vivid blue->cyan
      [.91 .85 .97] %vivid blue->magenta
      [.91 .97 .85] %vivid green->yellow
      [.85 .97 .91] %vivid green->cyan
      [.97 .91 .85] %vivid red->yellow
      [.97 .85 .91] %vivid red->magenta
      [.85 .871 .91] %grayed blue->cyan *1
      [.871 .85 .91] %grayed blue->magenta
      [.871 .91 .85] %grayed green->yellow *2
      [.85 .91 .871] %grayed green->cyan
      [.91 .871 .85] %grayed red->yellow
      [.91 .85 .871] %grayed red->magenta *3
    ];
    if(nargin==0)
      figure;
      colormap(CM);
      a=axes('Visible','off');
      cbh = colorbar('Location','West');
      set(cbh,'YTick',(1:length(colorNames))+1/2);
      set(cbh,'YTickLabel',colorNames);
    elseif(nargin>=1)
      color = CM(strcmp(colorName,colorNames),:);      
    end
  end
  
%% Copied library functions for standalone deployment:
  function fn = string2fieldname(s,bDontTruncate, bDontLowercaseFirstLetter, bOnlyDisallowFilesystemSpecialChars)
    if(nargin<2)bDontTruncate=false; end
    if(nargin<3)bDontLowercaseFirstLetter=false; end
    if(nargin<4)bOnlyDisallowFilesystemSpecialChars=false; end

    %Support cellstrings via recursion:
      if(iscellstr(s))
        fn = cellfun(@string2fieldname, s, 'UniformOutput', false);
        return;
      end
    if(~bOnlyDisallowFilesystemSpecialChars)
      disallowedSigns = [' ',10,13,9,'.:,;#''+-*^~={[]}()/\&%$�"!@<>|',26,181,'±½'];
    else
      disallowedSigns = ['/\:*?"<>|',10,13,9,26,181];
    end
    fn = '';
    bUpper = false;
    for i=1:length(s)
      %disp(s(i)); disp(double(s(i)));
      if(~ismember(s(i),disallowedSigns) && double(s(i))<=127) %exclude explicitly disallowed signs and all Unicode signs
        if(bUpper)
          fn = [fn,upper(s(i))];
        else
          fn = [fn,s(i)];
        end
        bUpper = false;
      else
        switch(s(i)) %optional replacementStrings for some disallowed signs:
          case '>'; fn = [fn,iif(i<length(s)&&s(i+1)=='=', iif(length(fn)>1&&fn(end)==upper(fn(end)),'gte','Gte'), iif(length(fn)>1&&fn(end)==upper(fn(end)),'gt','Gt'))];
          case '<'; fn = [fn,iif(i<length(s)&&s(i+1)=='=', iif(length(fn)>1&&fn(end)==upper(fn(end)),'lte','Lte'), iif(length(fn)>1&&fn(end)==upper(fn(end)),'lt','Lt'))];
          case '/'; fn = [fn,'Per'];
          case '+'; fn = [fn,'Plus'];
          case '-'; fn = [fn,'Minus'];
          case '('; fn = [fn,'_'];
          case '['; fn = [fn,'_'];
          case '{'; fn = [fn,'_'];
          case ';'; fn = [fn,'_'];
          case '%'; fn = [fn,'Prc'];
          case '#'; fn = [fn,'Hash'];
          case 181; fn = [fn,'mu'];
          case '±'; fn = [fn,'Pm'];
          case '½'; fn = [fn,'Half'];
          case '|'; fn = [fn,'_'];
        end
        bUpper = true;
      end
    end
    %lower first sign, if it is a letter and the second and third are lower case letters:
      if(~bDontLowercaseFirstLetter)
        if(length(fn)>=3 && fn(1)>='A' && fn(1)<='Z' && fn(2)>='a' && fn(2)<='z' && fn(3)>='a' && fn(3)<='z')
          fn(1) = lower(fn(1));
        end
      end
      %<-wird von verschiedenen Methoden benutzt, um column Names in Feldnamen zu übersetzen, z.B. "Internal Sample ID" in 'internalSampleID'
    %if the fieldname does not start with a letter, prepend a _:
      if(isempty(fn) || (~bOnlyDisallowFilesystemSpecialChars && ~(fn(1)>='a'&&fn(1)<='z' || fn(1)>='A'&&fn(1)<='Z')))
        warning(['fieldname "',fn,'" does not start with a letter; prefixing a "n"']);
        fn = ['n',fn];
      end
    %length limit:
      if(~bDontTruncate && length(fn)>63)
        warning(['fieldname "',fn,'" is too long (must have 63 characters at the maximum).']);
      end
  end
  function result = iif(condition, trueResult, falseResult)
    if(nargin<3) %useful for inline version of "if(condition)fncBody();end"
      if(isnumeric(trueResult) && isscalar(trueResult))
        falseResult = NaN; 
      elseif(ischar(trueResult))
        falseResult = ''; 
      else
        error('no default falseResult exists for this trueResult');
      end
    end 
    if(islogical(condition))
      if(length(condition)==1) %scalar condition:
        if(condition)
          result = trueResult;
        else
          result = falseResult;
        end
        if(isa(result,'function_handle') && nargin(result)==0)
          result = result();
        end
      else %vektoriell:
        %calculate needed result branche(s) provided as function handles:
          bTrueBranchNeeded = any(condition(:));
          bFalseBranchNeeded = any(~condition(:));
          if(isa(trueResult,'function_handle') && nargin(trueResult)==0 && bTrueBranchNeeded)
            trueResult = trueResult();
          end
          if(isa(falseResult,'function_handle') && nargin(falseResult)==0 && bFalseBranchNeeded)
            falseResult = falseResult();
          end
        %if the results are scalar, repmat them to condition size:
          if(length(trueResult)==1) trueResult=repmat(trueResult,size(condition)); end;
          if(length(falseResult)==1) falseResult=repmat(falseResult,size(condition)); end;
        %assert compatible sizes:
          assert(all(size(condition)==size(trueResult)), 'non-scalar condition and non-scalar trueResult with different array sizes are invalid syntax for iif');
          assert(all(size(condition)==size(falseResult)), 'non-scalar condition and non-scalar falseResult with different array sizes are invalid syntax for iif');
        %return result using condition as boolean pattern/stamp matrix:
          if(isnumeric(trueResult) && isnumeric(falseResult))
            result = nan(size(condition));
              result(condition) = trueResult(condition);
              result(~condition) = falseResult(~condition);
          elseif(iscell(trueResult) && iscell(falseResult))
            result = cell(size(condition));
              result(condition) = trueResult(condition);
              result(~condition) = falseResult(~condition);
          else
            error('non-scalar condition requires trueResult and falseResult to both be either numeric arrays or cell arrays');
          end
      end
    elseif(isa(condition,'function_handle'))
      if(nargin(condition)==1)
        if(isa(trueResult,'function_handle') && nargin(trueResult)==0)
          trueResult = trueResult();
        end
        condition = condition(trueResult);
      elseif(nargin(condition)==2)
        if(isa(trueResult,'function_handle') && nargin(trueResult)==0)
          trueResult = trueResult();
        end
        if(isa(falseResult,'function_handle') && nargin(falseResult)==0)
          falseResult = falseResult();
        end
        condition = condition(trueResult, falseResult);
      end
      result = iif(condition, trueResult, falseResult);
    else
      error('unsupported type for input parameter "condition"');
    end
  end
