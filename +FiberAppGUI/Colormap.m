% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function Colormap(hObject, eventdata)

FA = guidata(hObject);
FA.colorMap = utility.getColorMap(get(hObject, 'Label'));
set(gcf, 'Colormap', FA.colorMap);

set(get(get(hObject, 'Parent'), 'Children'), 'Checked', 'off');
set(hObject, 'Checked', 'on');

