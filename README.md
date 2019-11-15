# Matlab Profile Startup
Maltab profiles for Windows and Linux optimized for code overview and coding productivity in data science. (Code folding settings, keyboard shortcuts, layout, optional UTF-8 locale checks; three concurrent profiles with different window colors, optional task bar items for each profile with grouping of windows and figures.)
 
## Getting Started
**tl;dr** Download and extract the release for Windows or Linux and extract it. Move `profileStartup.m` to your development path that is part of the Matlab library path ("Home ribbon/Environment section/Set path button"). Adapt profile paths in launch scripts to your local installation (`.BAT` files for Windows, `.sh` files for Linux). Then start Matlab via a launch script. Optionally create task/launcher icons to group all Matlab windows originating from a particular profile (see below). In Matlab, configure (and, if needed, create) the folder for parallel jobs run by this profile. See installation steps below, if more details are needed.

## Main keyboard shortcuts configured for overview and productivity
- code folding:
  - `Alt+Left`: collapse current code folding section
  - `Alt+Right`: expand current code folding section
  - Hint: If a line is already collapsed, move the cursor to a non-collapsed line above to further collapse code hierarchically upwards via Alt+Left
  - `Alt+Shift+Left`: collapse all code folding sections in the current file
  - `Alt+Shift+Right`: expand all code folding sections in the current file
  - Hint: If you want to collapse all, but then go back and expand only the sections where your cursor was, simply use `Space, Alt+Shift+Left, Ctrl+Z`.  
  - Hint: to quickly add another code folding level, just wrap your code in an `if(true)...end` block; settings of this profile are already optimized to enable folding of `ifs`.
- change indentation multiple lines:
  - `Tab`: simple select lines to indent and press tab to indent
  - `Shift+Tab`: to outdent line, simply select them and press Shift+tab.
- searching:
  - `Alt+Shift+Up`: search selection upwards
  - `Alt+Shift+Down`: search selection downwards
  - `Alt+Up`: search last searched upwards
  - `Alt+Down`: search last searched downwards
- navigation:
  - `Alt+PgUp`: go to previous `%%` code section
  - `Alt+PgDown`: go to next `%%` code section
  - `Alt+Shift+PgUp`: go to previous occurrence of highlighted variable
  - `Alt+Shift+PgDOwn`: go to next occurrence of highlighted variable
  - `Ctrl+PgUp`: go to previous file in editor
  - `Ctrl+PgDown`: go to next file in editor
- code execution and console:
  - `Ctrl+0`: go to console
  - `Ctrl+Shift+0`: go back to editor
  - `Ctrl+Enter`: execute current `%%` code section
  - `Ctrl+E`: execute currently selected code
- un/comment multiple lines:
  - `Ctrl+R`: comment selected lines
  - `Ctrl+T`: uncomment selected lines
- debugging and related:
  - `Ctrl+B`: set/remove debugging breakpoint (red dot) fr the current code line
  - `Ctrl+D`: open defining file of function/class under cursor
  - `F11`: debugging/step into function called in this line (if any; i.e. one level deeper in the stack)
  - `Shift+F11`: debugging/step out (one stack level up, back to calling line of code)
  - `F10`: debugging/step over (execute current line completey including any subfunction calls, unless the contain defined breakpoints)
- diverse:
  - `Ctrl+Shift+W`: Close current file.
  - `Ctrl+Q`: disabled to prevent accidential usage (closes Matlab usually; also enabled the "do you really want to close Matlab" confirmation dialog againt accidental close commands).
- You can see and further adapt all keyboard shortcuts at "Home ribbon/Environment section/Preferences button: Matlab/Keyboard/Shortcuts". 

## Installation steps
- Download and extract the release ZIP for Windows or Linux into a temporary directory.
- Install the `profileStartup` tool:
  - If you do not have one, yet, create a `libRootFolder` for your own development and libraries.
  - Move the `ZIP\profileStartup` folder into your `libRootFolder`.
  - If not yet done, install Matlab as usual. Launch Matlab as usual (i.e. using the default profile).
  - In Matlab, add the `profileStartup` subfolder in your `libRootFolder` to your library path via the "Home ribbon/Environment section/Set path button". Save your paths. If you don't have access rights to edit the global Matlab library paths, see the `startup.m` workaround in details below.
- Move Matlab profile stubs to their target location:
  - In Windows, the default location for Matlab profiles is in `%AppData%\MathWorks\MATLAB`, e.g. `C:\Users\MG\AppData\Roaming\MathWorks\MATLAB\primary`. Move the folders `primary`, `secondary` and `tertiary` containing settings files there.
  - In Linux, you may use any folder you wish, as long as your user account has full read/write access there.
  - Linux-only step: Matlab profiles in Linux contain a Chromium browser used for browsing the Matlab docu. As they are version-dependent (and relatively large), I do not include them in profile releases. If Matlab does not automatically do this for you and/or if you have problems viewing the Matlab docu in Ubuntu, browse to your delault profile at `~/.matlab` and copy the sub folders `LightweightBrowser` und `HtmlPanel` from there into your `primary`, `secondary` and `tertiary` profile folders. Then relaunch Matlab.
- Adapt paths in launcher scripts to your installation:
  - Open the launch scripts (like `startMatlabDirect_primaryProfile.BAT` or `startMatlabDirect_primaryProfile.sh`).
  - Adapt the path set for the `MATLAB_PREFDIR` environment variable accordingly.
  - Set or cd to the path, from where you want to launch Matlab, typically this is your `libRootFolder`.
  - Adapt the path to the Matlab executable file, if necessary.
- Launch Matlab via the launcher script.
  - `profileStartup` should be the first command executed after the Matlab engine (and possibly `startup.m`) has loaded. 
  - Open the editor via `edit` in the console, if it is not open, yet. You may want to test and get used to keyboard shortcuts.
  
- To get individual task bar launcher icons with profile-specific grouping of windows in Windows, continue with Create launch icons below.
- To avoid interference between profiles for parallel background jobs, create/configure separate  `JobStorageLocation`s. ("Home ribbon/Environment section/Parallel.../Create and Manage Clusters". Then edit the local profile and adapt the path in the `JobStorageLocation` field.)
- If you get a UTF-8 warning, configure your editor encoding as described below in details.

## Details

### Startup procedure explained in detail
For a completely configured environment, startup steps are as follows:
- You click on the task bar icon for the intended Matlab profile.
- The OS executes the launcher script like `startMatlabDirect_primaryProfile.BAT` in Windows or `startMatlabDirect_secondaryProfile.sh` in Ubuntu.
- The script sets the `MATLAB_PREFDIR` environment variable to the directory containing profile setting like `matlab.settings`.
- The Matlab executable is launched by the script and settings like keyboard shortcuts from the files in the configured profile folder.
- If a `startup.m` file is present in the startup directory, it is executed.
- Once the Matlab engine is loaded, it executes, e.g.n `profileStartup('primary profile','grayed blue->cyan');`. This will append `'primary profile'` to the Matlab window title, apply the chosen window background color, warn if the locale is not set to UTF-8 (see below) and set a unique AppID if run on Windows.
- Once the AppID is set, all windows from this Matlab will be grouped behind the task bar item you clicked first. In this way, you can have multiple icons for different concurrently running profiles.

### Create launcher icons for your task bar
- Windows:
  - Unpin any existing Matlab icon from the taskbar and close Matlab, if needed.
  - The Windows task bar groups windows by their AppID. Normally, all windows from all `Matlab.exe` process instances are grouped behind one icon, as all have the same AppID. `profileStartup.m` calls the system function `SetCurrentProcessExplicitAppUserModelID` to give each profile separate AppID.
  - To create a Windows task bar icon for your profile, you have to first launch Matlab as described above and **wait** for `profileStartup.m` to assign the non-default AppID (the profile mnemonic will alse be appended to the Window title). Once it is, right-click the icon in the Windows taskbar and choose `Pin to taskbar`.
  - This creates a shortcut file in the folder `%AppData%\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar`. Open a file explorer Window and enter this path address. There, find the newly created shortcut file names like `MATLAB R2018a` and rename it to something unique like `MATLAB R2018a - primary`.
  - Right-click the shortcut file and click Properties:
    - target: Currently it launches `Matlab.exe` directly, but we need to start this profile again with the startup batch file. So edit the target to point to the `.BAT` that you used to start the Matlab instance you pinned. 
    - start in: You should enter your custom development root path `libRootFolder` in the "Start in" field. 
    - icon: As the batch file has no icon, also click on "Change Icon..." and enter, e.g., `%ProgramFiles%\MATLAB\R2018a\bin\matlab.exe` (or the path to the Matlab version you have installed).
    - optional: to hide the cmd window of the batch file, select to start in a minimized window from the dropdown.
    - close the properties diaglog by clicking OK
  - Exit the running Matlab and test the created launcher icon. It should directly load Matlab again and windows from this profile should be grouped behind this pinned task bar icon once `profileStartup.m` has run. 
  - You may want to repeat these steps to also create icons for your secondary and tertiary (and maybe more) Matlab profiles.
- Linux: Just create a launcher icon as usual for your chosen desktop environment. It should launch, for example, `startMatlabDirect_primaryProfile.sh` and may point to `matlab_icon.png` for the icon. No special support from `profileStartup.m` to group windows from the same Matlab profile behind the same task bar icon is provided for Linux, but some Linux desktops automatically group windows by their parent process ID (rather than by AppID as in Windows) and thus do not require special handling.

### Configure/customize your Matlab library path via `startup.m`
If a file named `startup.m` is located in the folder from which the launch script starts Matlab, it will be executed once the engine has loaded. This is useful to change, for example, the Matlab library path if your user account does not have access rights to change the global path definition. To use it, just create a `startup.m` in your `libRootFolder` if this is your Matlab start directory. See the `startup.m` included in the release for Linux for an example of how to set/customize library paths there. Make sure that the path containing `profileStartup.m` is added there, if it is not contained in the global path definition.

### Configure the dir for parallel jobs separately for each profile
To avoid interference between profiles when using parallel computing or background jobs, configure a separate job directory for each profile. (This is already in the config, but you may need to adapt or create the path on your disk.) To do so, click "Home ribbon/Environment section/Parallel.../Create and Manage Clusters". Then edit the local profile and adapt the path in the field `JobStorageLocation`.

### Configure UTF-8 locale
On Windows, Matlab does not by default use the universal UTF-8 locale for text files. When changing operating systems or collaborating with others using Linux on the same files (e.g. on a common file share), then this configuration may permanently replace all special characters (like German umlauts `äüö`) by the same placeholder sign. To avoid this loss of information, we recommend changing the locale to UTF-8 on Windows as well. To do so:
- go to your Matlab installation directory, e.g. `C:\Program Files\MATLAB\R2016a\bin`
- the `lcdata.xml` in this folder configures the locale Matlab uses. If it is small and also a `lcdata_utf8.xml` is present in the same directory, the first step to enable locale customization is to overwrite `lcdata.xml` by `lcdata_utf8.xml`.
- then open `lcdata.xml` and edit it as follows: Search for sections
    ```
    <encoding name="windows-1252" jvm_encoding="Cp1252">
      <encoding_alias name="1252"/>
    </encoding>
    ```
  and
    ``` 
    <encoding name="ISO-8859-1">
      <encoding_alias name="ISO8859-1"/>
    </encoding>
    ``` 
  and either delete them or comment them out (using `<!-- ... -->`).
  Then add aliases for these encodings into the "UTF-8" section: 
    ```
    <encoding name="UTF-8">
      <encoding_alias name="utf8"/>
      <encoding_alias name="ISO8859-1"/>
      <encoding_alias name="1252"/>
    </encoding>
    ```
- Finally, you can control success with the `feature('locale')` command in Matlab. It should now list UTF locales. If not, you may need to repeat above steps with whatever ISO encoding is listed by this command on your workstation.
