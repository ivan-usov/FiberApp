% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function hide(hObject, eventdata)
tag = get(hObject, 'Tag');

% Make menu item and toggle tool unchecked
set(findobj('Type', 'uimenu', 'Tag', tag), 'Checked', 'off');
set(findobj('Type', 'uitoggletool', 'Tag', tag), 'State', 'off');

% Hide the panel and update position of others
p = findobj('Type', 'uipanel', 'Tag', tag);
set(p, 'Visible', 'off');
FA = guidata(hObject);
FA.userPanel(FA.userPanel == p) = [];

