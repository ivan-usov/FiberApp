function AddFiber(hObject, eventdata)
FA = guidata(hObject);

% Mask input
if FA.setMask
    [mx, my, ms] = FA.getMask;
    mr = arrayfun(@(xc,yc,ms) rectangle('Position', [xc-ms/2, yc-ms/2, ms, ms], ...
        'LineStyle', ':', 'EdgeColor', FA.maskLineColor, ...
        'LineWidth', FA.maskLineWidth), mx, my, ms);
else
    mx = []; my = []; ms = []; mr = [];
end

% Initialise fiber
if FA.aStar
    [x, y] = FA.getFiberAStar;
else
    [x, y] = FA.getFiber;
end

if length(x) < 2 % if only right click occurs
    if FA.setMask; delete(mr); end
    return
end

% Calculate points along the fiber separated by a specified distance
xy = utility.distributePoints([x; y], FA.step);
% xy = [x; y];

% Save mask and fiber data
FA.curIm.mask{end+1} = [mx; my; ms];
FA.curIm.xy{end+1} = xy;
FA.curIm.z{end+1} = utility.interp2D(FA.im, xy(1,:), xy(2,:), FA.zInterpMethod);

% Save fiber rectangle
FA.fibRect(:,end+1) = [min(xy,[],2); max(xy,[],2)];

% Update the line and put a selection on it
FA.fibLine(end+1) = line('XData', xy(1,:), 'YData', xy(2,:));
FA.sel = length(FA.fibLine);

% Clean image from temporary mask dashed edges
delete(mr);

% Data is modified
FA.isDataModified = true;

% Fit fiber, if checkbox is on
if FA.autoFit; FiberAppGUI.FitFiber(hObject, eventdata); end

