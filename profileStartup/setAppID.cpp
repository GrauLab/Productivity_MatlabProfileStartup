//Note:_ mex with additional library:
  //mex('D:\(Eigene Daten) permanent offen\(permanent offen) Matlab Analysis Tools\MIC Coding\Basic Tools\profileStartup\setAppID.cpp','shlwapi.lib','Propsys.lib')

//External sources used:
  //#source: http://code.msdn.microsoft.com/windowsdesktop/CppWin7TaskbarAppID-9be7f36a

//Headers:
  //C RunTime Header Files 
    #include <stdlib.h> 
    #include <malloc.h> 
    #include <memory.h> 
    #include <tchar.h> 
  //include the matlab mex function stuff
    #include "mex.h"
  //Windows Header Files: 
    #include <windows.h> 
    #include <windowsx.h> 
  //Header Files for Windows 7 Taskbar features 
    #include <shobjidl.h> 
    #include <propkey.h> 
    #include <propvarutil.h> 
    #include <shlwapi.h>
    #include <shlobj.h> 
    #include <shellapi.h> 

//Local Headers:
  #define IID_PPV_ARGS(ppType) __uuidof(**(ppType)), IID_PPV_ARGS_Helper(ppType)

//declare variables:
  DWORD processID; 
  bool bDebug = true;
  HRESULT hr;
//helper functions:  
  wchar_t* str2unicode(char* sA) {
    int requiredSize = mbstowcs(NULL, sA, 0);
    wchar_t* sW = (wchar_t*) malloc((requiredSize+1)*sizeof(wchar_t)); //<-Add one to leave room for the NULL terminator.
    mbstowcs(sW, sA, requiredSize+1);
    return sW;
  }
  char* unicode2str(wchar_t* sW) {
    int requiredSize = wcstombs(NULL, sW, 0);
    char* sA = (char *)malloc(requiredSize+1);
    wcstombs(sA, sW, requiredSize+1);
    return sA;
  }
  
//Callback function, this is the bit that sets the window text
  bool SetAppIDForSpecificWindow(HWND hWnd, LPARAM lParam) { 
    //Local vars:
      DWORD dwID;
      PROPVARIANT pv; 
    //get the process of the window this was called on:
      GetWindowThreadProcessId(hWnd, &dwID);
      //if(bDebug) mexPrintf("<- hwnd=%d, process ID=%d\n", hWnd, dwID);
    //if it is our matlab instance, set the title text
      if(dwID != processID) return true; //continue enumerating windows.
    //Get window title:
      if(bDebug) {
        int nCharacters = GetWindowTextLength(hWnd);
        char* szBuffer = new char[nCharacters+1];
        GetWindowText(hWnd, szBuffer, nCharacters+1);
        mexPrintf("<- operating on window hWnd=%d, window title=%s with lParam=%s\n", hWnd, szBuffer, unicode2str((wchar_t *)lParam));
      }
    //Get current window IPropertyStore:
      IPropertyStore *pps; 
      hr = SHGetPropertyStoreForWindow(hWnd, IID_PPV_ARGS(&pps)); 
      if(!SUCCEEDED(hr)) {
        mexPrintf("setAppID ERROR: SHGetPropertyStoreForWindow(hWnd, IID_PPV_ARGS(&pps)) unsuccessful.\n");
        //Cleanup:
          pps->Release();
        return false;
      }
      if(bDebug) mexPrintf("<- SHGetPropertyStoreForWindow(hWnd, IID_PPV_ARGS(&pps)); successful.\n");
    //Get previous AppID:
      hr = pps->GetValue(PKEY_AppUserModel_ID, &pv);
      if(!SUCCEEDED(hr)) {
        mexPrintf("setAppID ERROR: pps->GetValue(PKEY_AppUserModel_ID, &pv); unsuccessful.\n");
        //Cleanup:
          PropVariantClear(&pv); 
          pps->Release();
        return false;
      }
      WCHAR szPreviousAppID[128];
      hr = PropVariantToString(pv, szPreviousAppID, ARRAYSIZE(szPreviousAppID));
      if(!SUCCEEDED(hr)) {
        mexPrintf("setAppID ERROR: PropVariantToString(pv, szPreviousAppID, ARRAYSIZE(szTitle)); unsuccessful.\n");
        //Cleanup:
          PropVariantClear(&pv); 
          pps->Release();
        return false;
      }
      if(bDebug) mexPrintf("<- pps->GetValue(PKEY_AppUserModel_ID, &pv); successful; previous AppID=%s\n", unicode2str(szPreviousAppID));
    //Initialize new AppID:
      hr = InitPropVariantFromString((LPCWSTR)lParam, &pv); 
      if(!SUCCEEDED(hr)) {
        mexPrintf("setAppID ERROR: InitPropVariantFromString((LPCWSTR)lParam, &pv); unsuccessful.\n");
        //Cleanup:
          PropVariantClear(&pv); 
          pps->Release();
        return false;
      }
    //Set new key/value pair in the window's property store:
      hr = pps->SetValue(PKEY_AppUserModel_ID, pv); 
      if(!SUCCEEDED(hr)) {
        mexPrintf("setAppID ERROR: pps->SetValue(PKEY_AppUserModel_ID, &lParam).\n");
        //Cleanup:
          PropVariantClear(&pv); 
          pps->Release();
        return false;
      }
      if(bDebug) mexPrintf("<- pps->SetValue(PKEY_AppUserModel_ID, pv); successful.\n");
    //Apply new properties:
      //UpdateWindow(hWnd); 
      if(bDebug) mexPrintf("<- UpdateWindow(hWnd); successful.\n");
    //Cleanup:
      PropVariantClear(&pv);
      pps->Release();
    //continue enumerating windows:
      return true;
  }

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
  bDebug = nrhs>=2 && mxIsLogicalScalar(prhs[1]) && mxGetScalar(prhs[1])==1;
  if(bDebug) mexPrintf("setAppID.cpp: mexFunction entry point.\n");      
  //get the process id of this instance of matlab
    processID = GetCurrentProcessId(); 
    if(bDebug) mexPrintf("<- Matlab process ID: %d\n", processID);
  if(nrhs > 0) {
    //Get AppID parameter:
      LPCSTR sAppID = (LPCSTR)mxArrayToString(prhs[0]); //get parameter as a char* string
      if(bDebug) mexPrintf("<- LPCSTR sAppID: %s\n", sAppID);
    //get all open windows and call the SetTitleEnum function on them
      hr = EnumWindows((WNDENUMPROC)SetAppIDForSpecificWindow, (LPARAM)(str2unicode((char*)sAppID)));
      if(!SUCCEEDED(hr)) mexPrintf("setAppID ERROR: EnumWindows((WNDENUMPROC)SetAppIDForSpecificWindow, (LPARAM)sAppIDW);\n");
    //Cleanup:
      mxFree((void*)sAppID);
  }
}