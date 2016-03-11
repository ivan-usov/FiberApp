function updatePanelPosition(this)
% Update the open panels positions

figPos = get(gcf, 'Position');

% Set user panels position
x = 1;
y = 1 + figPos(4);
for k = 1:length(this.openPanels)
    panPos = get(this.openPanels(k), 'Position');
    if (y<=panPos(4) && k~=1)
        x = x + panPos(3) + 1;
        y = 1 + figPos(4);
    end
    
    y = y - panPos(4);
    
    panPos(1) = x;
    panPos(2) = y;
    set(this.openPanels(k), 'Position', panPos);
end

% Set introduction string position (string width = 400, string height = 100, gaps = 10)
set(findobj('Type', 'uicontrol', 'Tag', 'intro_string'), ...
    'Position', [x + panPos(3) + 10, figPos(4) - 100 - 10, 400, 100]);

% Set scroll panel position
scrollPanel = findobj('Type', 'uipanel', 'Tag', 'imscrollpanel');
if ~isempty(this.openPanels)
    x = x + panPos(3) + 1;
end
if 1+figPos(3)-x <= 0 % if there is no room for the scroll panel
    set(scrollPanel, 'Position', [x, 1, 1, figPos(4)]);
else % otherwise fill the rest of the window
    set(scrollPanel, 'Position', [x, 1, 1+figPos(3)-x, figPos(4)]);
end

