function Zoom(hObject, eventdata, dir)
FA = guidata(hObject);
switch dir
    case 'in'
        FA.pan_zoom('z_in');
    case 'out'
        FA.pan_zoom('z_out');
    case 'actual'
        FA.pan_zoom('z_actual');
end

