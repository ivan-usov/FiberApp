function show(hObject, eventdata)
tag = get(hObject, 'Tag');

% Make menu item and toggle tool checked
set(findobj('Type', 'uimenu', 'Tag', tag), 'Checked', 'on');
set(findobj('Type', 'uitoggletool', 'Tag', tag), 'State', 'on');

% Show the panel and update position
p = findobj('Type', 'uipanel', 'Tag', tag);
set(p, 'Visible', 'on');
FA = guidata(hObject);
FA.userPanel(end+1) = p;

