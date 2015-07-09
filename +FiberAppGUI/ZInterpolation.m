% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function ZInterpolation(hObject, eventdata)

FA = guidata(hObject);
FA.zInterpMethod = get(hObject, 'Label');

set(get(get(hObject, 'Parent'), 'Children'), 'Checked', 'off');
set(hObject, 'Checked', 'on');

