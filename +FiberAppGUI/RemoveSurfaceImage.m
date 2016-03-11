function RemoveSurfaceImage(hObject, eventdata)

FA = guidata(hObject);
hwb = waitbar(0.1, 'Please wait...', 'WindowStyle', 'modal', 'CloseRequestFcn', '');
% Tophat filter (remove surface)
FA.im = imtophat(FA.im, strel('square', 75));
waitbar(0.9);
FA.updateImage('PreserveView');
delete(hwb);

