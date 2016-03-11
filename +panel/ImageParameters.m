function p = ImageParameters
ph = 144; % panel height
pTitle = 'Image Parameters';
pTag = 'ImageParameters';
% Panel and hide button
p = uipanel(gcf, 'Units', 'pixels', 'FontWeight', 'bold', ...
    'BorderType', 'line', 'HighlightColor', [0.5 0.5 0.5], ...
    'Title', pTitle, ...
    'Tag', pTag, ...
    'Position', [-231 1 230 ph]);
uicontrol(p, 'Style', 'pushbutton', 'String', '-', ...
    'HitTest', 'off', ...
    'Tag', pTag, ...
    'Callback', @panel.hide, ...
    'Position', [211 ph-25 18 16]);
% Panel components --------------------------------------------------------
% Filename
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Filename:', ...
    'Position', [10 ph-38 75 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Tag', 'e_name', ...
    'Callback', @ImageParameters_Name, ...
    'Position', [85 ph-42 125 22]);
% Size
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Size:', ...
    'Position', [10 ph-61 75 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'pix', ...
    'Position', [188 ph-61 35 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Tag', 'e_sizeX', ...
    'Callback', @ImageParameters_Size, ...
    'Position', [85 ph-65 51 22]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Tag', 'e_sizeY', ...
    'Callback', @ImageParameters_Size, ...
    'Position', [135 ph-65 51 22]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-84 35 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Tag', 'e_sizeX_nm', ...
    'Callback', @ImageParameters_Size, ...
    'Position', [85 ph-88 51 22]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Tag', 'e_sizeY_nm', ...
    'Callback', @ImageParameters_Size, ...
    'Position', [135 ph-88 51 22]);
% Contrast
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Contrast:', ...
    'Position', [10 ph-107 75 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'units', ...
    'Position', [188 ph-107 35 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_viewMinZ', ...
    'Callback', @ImageParameters_ViewZ, ...
    'Position', [85 ph-111 51 22]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_viewMaxZ', ...
    'Callback', @ImageParameters_ViewZ, ...
    'Position', [135 ph-111 51 22]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-130 35 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_viewMinZ_nm', ...
    'Callback', @ImageParameters_ViewZ, ...
    'Position', [85 ph-134 51 22]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_viewMaxZ_nm', ...
    'Callback', @ImageParameters_ViewZ, ...
    'Position', [135 ph-134 51 22]);

function ImageParameters_Name(hObject, eventdata)
FA = guidata(hObject);
set(hObject, 'String', FA.name);
errordlg('Access denied');

function ImageParameters_Size(hObject, eventdata)
FA = guidata(hObject);
switch get(hObject, 'Tag')
    case 'e_sizeX'
        set(hObject, 'String', FA.sizeX);
        errordlg('Access denied');
        
    case 'e_sizeY'
        set(hObject, 'String', FA.sizeY);
        errordlg('Access denied');
        
    case 'e_sizeX_nm'
        set(hObject, 'String', FA.sizeX_nm);
        errordlg('Access denied');
        
    case 'e_sizeY_nm'
        set(hObject, 'String', FA.sizeY_nm);
        errordlg('Access denied');
end

function ImageParameters_ViewZ(hObject, eventdata)
FA = guidata(hObject);
val = sscanf(get(hObject, 'String'), '%f', 1);
switch get(hObject, 'Tag')
    case 'e_viewMinZ'
        if isempty(val)
            set(hObject, 'String', FA.viewMinZ);
            errordlg('Z-min must be a number', 'Error');
            return
        end
        
        FA.viewMinZ = round(val);
        FA.viewMinZ_nm = FA.viewMinZ*FA.scaleZ;
        
    case 'e_viewMaxZ'
        if isempty(val)
            set(hObject, 'String', FA.viewMaxZ);
            errordlg('Z-max must be a number', 'Error');
            return
        end
        
        FA.viewMaxZ = round(val);
        FA.viewMaxZ_nm = FA.viewMaxZ*FA.scaleZ;
        
    case 'e_viewMinZ_nm'
        if isempty(val)
            set(hObject, 'String', FA.viewMinZ_nm);
            errordlg('Z-min (nm) must be a number', 'Error');
            return
        end
        
        FA.viewMinZ = round(val/FA.scaleZ);
        FA.viewMinZ_nm = FA.viewMinZ*FA.scaleZ;
        
    case 'e_viewMaxZ_nm'
        if isempty(val)
            set(hObject, 'String', FA.viewMaxZ_nm);
            errordlg('Z-max (nm) must be a number', 'Error');
            return
        end
        
        FA.viewMaxZ = round(val/FA.scaleZ);
        FA.viewMaxZ_nm = FA.viewMaxZ*FA.scaleZ;
end

FA.updateImage('PreserveContrast', 'PreserveView');

