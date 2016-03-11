function hidePanel(this, tag)
% Make menu item and toggle tool unchecked
set(findobj('Type', 'uimenu', 'Tag', tag), 'Checked', 'off');
set(findobj('Type', 'uitoggletool', 'Tag', tag), 'State', 'off');

% Hide the panel and update position of others
p = this.panels.(tag);
set(p, 'Visible', 'off');

this.openPanels(this.openPanels == p) = [];

