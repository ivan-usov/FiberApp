% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function FitAllFibers(hObject, eventdata)
prev = 0;
hwb = waitbar(prev, 'Please wait...', 'CloseRequestFcn', '');

% Fit all fibers
FA = guidata(hObject);
for k = 1:length(FA.curIm.xy)
    FA.sel = k;
    FiberAppGUI.FitFiber(hObject, eventdata);
    % Redraw and update waitbar every single percent (not every single fiber)
    new = round(100*k/length(FA.curIm.xy))/100;
    if (new ~= prev)
        prev = new;
        waitbar(new);
    end
end

% Remove the progress bar
delete(hwb);

