function RemoveMask(hObject, eventdata)
FA = guidata(hObject);

% Check if there is selected fiber
if FA.sel == 0; return; end

% Delete mask from memory and image
FA.curIm.mask{FA.sel} = [];
delete(FA.maskLine);
FA.maskLine = [];

% Data is modified
FA.isDataModified = true;

% Fit fiber, if checkbox is on
if FA.autoFit; FiberAppGUI.FitFiber(hObject, eventdata); end

