function p = FiberDataInformation
ph = 209; % panel height
pTitle = 'Fiber Data Information';
pTag = 'FiberDataInformation';
% Panel and hide button
p = uipanel(gcf, 'Units', 'pixels', 'FontWeight', 'bold', ...
    'BorderType', 'line', 'HighlightColor', [0.5 0.5 0.5], ...
    'Visible', 'off', ...
    'Title', pTitle, ...
    'Tag', pTag, ...
    'Position', [0 0 230 ph]);
FA = guidata(gcf);
uicontrol(p, 'Style', 'pushbutton', 'String', '-', ...
    'HitTest', 'off', ...
    'Callback', @(h,ed) FA.hidePanel(pTag), ...
    'Position', [211 ph-25 18 16]);
% Panel components --------------------------------------------------------
% Data filename
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Data filename:', ...
    'Position', [10 ph-38 75 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', '*', 'Visible', 'off', ...
    'Position', [212 ph-38 5 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Tag', 'e_dataName', ...
    'Callback', @FiberDataInformation_DataName, ...
    'Position', [85 ph-42 125 22]);
% Number of images
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Number of images:', ...
    'Position', [10 ph-61 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'Tag', 't_nIm', ...
    'String', '0', ...
    'Position', [135 ph-61 51 14]);
% Number of fibers
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Number of fibers', ...
    'Position', [10 ph-84 100 14]);
% --- current image
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'current image:', ...
    'Position', [15 ph-107 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'Tag', 't_nFibCur', ...
    'String', '0', ...
    'Position', [135 ph-107 51 14]);
% --- total
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'total:', ...
    'Position', [15 ph-130 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'Tag', 't_nFibTot', ...
    'String', '0', ...
    'Position', [135 ph-130 51 14]);
% Selected fiber
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Selected fiber', ...
    'Position', [10 ph-153 100 14]);
% --- length
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'length:', ...
    'Position', [15 ph-176 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'Tag', 't_fibLen', ...
    'Position', [135 ph-176 51 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-176 35 14]);
% --- average height
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'average height:', ...
    'Position', [15 ph-199 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'Tag', 't_fibAvh', ...
    'Position', [135 ph-199 51 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-199 35 14]);

function FiberDataInformation_DataName(hObject, eventdata)
FA = guidata(hObject);
set(hObject, 'String', FA.dataName);
errordlg('Access denied');

