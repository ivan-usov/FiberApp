%ADDMASK "Add Mask" menu item callback

function AddMask(hObject, eventdata)
FA = guidata(hObject);

% Check if there is selected fiber
if FA.sel == 0; return; end

[mx, my, ms] = FA.getMask;

% Save mask data
FA.curIm.mask{FA.sel} = cat(2, FA.curIm.mask{FA.sel}, [mx; my; ms]);

% Draw new mask rectangles
FA.maskLine = [FA.maskLine arrayfun(@(mx,my,ms) rectangle('Position', ...
    [mx-ms/2, my-ms/2, ms, ms], 'EdgeColor', FA.maskLineColor, ...
        'LineWidth', FA.maskLineWidth), mx, my, ms)];

% Data is modified
FA.isDataModified = true;

% Fit fiber, if checkbox is on
if FA.autoFit; FiberAppGUI.FitFiber(hObject, eventdata); end
