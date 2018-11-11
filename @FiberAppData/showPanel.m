%SHOWPANEL Show panel

function showPanel(this, tag)

% Make menu item and toggle tool checked
set(findobj('Type', 'uimenu', 'Tag', tag), 'Checked', 'on');
set(findobj('Type', 'uitoggletool', 'Tag', tag), 'State', 'on');

% Show the panel and update position
p = this.panels.(tag);
set(p, 'Visible', 'on');

this.openPanels(end+1) = p;
