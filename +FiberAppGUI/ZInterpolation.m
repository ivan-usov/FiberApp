%ZINTERPOLATION "Z Interpolation" menu item callback

function ZInterpolation(hObject, eventdata)

FA = guidata(hObject);
FA.zInterpMethod = get(hObject, 'Label');

set(get(get(hObject, 'Parent'), 'Children'), 'Checked', 'off');
set(hObject, 'Checked', 'on');
