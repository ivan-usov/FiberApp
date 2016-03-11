function p = FiberTrackingParameters
ph = 305; % panel height
pTitle = 'Fiber Tracking Parameters';
pTag = 'FiberTrackingParameters';
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
% Contour type
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Contour type:', ...
    'Position', [10 ph-38 75 14]);
uicontrol(p, 'Style', 'radiobutton', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'Tag', 'rb_open', ...
    'String', 'open', ...
    'Value', FA.isFiberOpen, ...
    'Callback', @FiberTrackingParameters_IsFiberOpen, ...
    'Position', [85 ph-42 50 24]);
uicontrol(p, 'Style', 'radiobutton', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'Tag', 'rb_closed', ...
    'String', 'closed', ...
    'Value', ~FA.isFiberOpen, ...
    'Callback', @FiberTrackingParameters_IsFiberOpen, ...
    'Position', [135 ph-42 60 24]);
% Fiber intensity
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Fiber intensity:', ...
    'Position', [10 ph-61 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'units', ...
    'Position', [188 ph-61 35 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_fiberIntensity', ...
    'String', FA.fiberIntensity, ...
    'Callback', @FiberTrackingParameters_FitParameter, ...
    'Position', [135 ph-65 51 22]);
% --- button
uicontrol(p, 'Style', 'pushbutton', 'Enable', 'off', ...
    'Callback', @FiberTrackingParameters_SetFiberIntensity, ...
    'Position', [165 ph-64 20 20]);
% Alpha
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Alpha:', ...
    'Position', [10 ph-84 100 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_alpha', ...
    'String', FA.alpha, ...
    'Callback', @FiberTrackingParameters_FitParameter, ...
    'Position', [135 ph-88 51 22]);
% Beta
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Beta:', ...
    'Position', [10 ph-107 100 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_beta', ...
    'String', FA.beta, ...
    'Callback', @FiberTrackingParameters_FitParameter, ...
    'Position', [135 ph-111 51 22]);
% Gamma
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Gamma:', ...
    'Position', [10 ph-130 100 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_gamma', ...
    'String', FA.gamma, ...
    'Callback', @FiberTrackingParameters_FitParameter, ...
    'Position', [135 ph-134 51 22]);
% Kappa1
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Kappa1:', ...
    'Position', [10 ph-153 100 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_kappa1', ...
    'String', FA.kappa1, ...
    'Callback', @FiberTrackingParameters_FitParameter, ...
    'Position', [135 ph-157 51 22]);
% Kappa2
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Kappa2:', ...
    'Position', [10 ph-176 100 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_kappa2', ...
    'String', FA.kappa2, ...
    'Callback', @FiberTrackingParameters_FitParameter, ...
    'Position', [135 ph-180 51 22]);
% Step
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Step:', ...
    'Position', [10 ph-199 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'pix', ...
    'Position', [188 ph-199 35 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_step', ...
    'String', FA.step, ...
    'Callback', @FiberTrackingParameters_Step, ...
    'Position', [135 ph-203 51 22]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-222 35 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_step_nm', ...
    'String', FA.step_nm, ...
    'Callback', @FiberTrackingParameters_Step, ...
    'Position', [135 ph-226 51 22]);
% Iterations
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Iterations:', ...
    'Position', [10 ph-245 100 14]);
uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', 'Enable', 'off', ...
    'BackgroundColor', [1 1 1], ...
    'Tag', 'e_iterations', ...
    'String', FA.iterations, ...
    'Callback', @FiberTrackingParameters_FitParameter, ...
    'Position', [135 ph-249 51 22]);
% Automatically apply to new fibers
uicontrol(p, 'Style', 'checkbox', 'Enable', 'off', ...
    'Value', FA.autoFit, ...
    'String', 'Automatically apply to new fibers', ...
    'Callback', @FiberTrackingParameters_AutoFit, ...
    'Position', [10 ph-272 195 20]);
% Use A* pathfinding algorithm
uicontrol(p, 'Style', 'checkbox', 'Enable', 'off', ...
    'Value', FA.aStar, ...
    'String', 'Use A* pathfinding algorithm', ...
    'Callback', @FiberTrackingParameters_AStar, ...
    'Position', [10 ph-295 195 20]);

function FiberTrackingParameters_IsFiberOpen(hObject, eventdata)
FA = guidata(hObject);
switch get(hObject, 'Tag')
    case 'rb_open'
        FA.isFiberOpen = true;
        set(hObject, 'Value', 1);
        set(findobj('Tag','rb_closed'), 'Value', 0);
        
    case 'rb_closed'
        FA.isFiberOpen = false;
        set(hObject, 'Value', 1);
        set(findobj('Tag','rb_open'), 'Value', 0);
end

function FiberTrackingParameters_FitParameter(hObject, eventdata)
FA = guidata(hObject);
val = sscanf(get(hObject, 'String'), '%f', 1);
switch get(hObject, 'Tag')
    case 'e_alpha'
        if isempty(val)
            set(hObject, 'String', FA.alpha);
            errordlg('Alpha must be a number', 'Error');
            return
        end
        FA.alpha = val;
        FA.curIm.alpha = FA.alpha;
        
    case 'e_beta'
        if isempty(val)
            set(hObject, 'String', FA.beta);
            errordlg('Beta must be a number', 'Error');
            return
        end
        FA.beta = val;
        FA.curIm.beta = FA.beta;
        
    case 'e_gamma'
        if isempty(val)
            set(hObject, 'String', FA.gamma);
            errordlg('Gamma must be a number', 'Error');
            return
        end
        FA.gamma = val;
        FA.curIm.gamma = FA.gamma;
        
    case 'e_kappa1'
        if isempty(val)
            set(hObject, 'String', FA.kappa1);
            errordlg('Kappa1 must be a number', 'Error');
            return
        end
        FA.kappa1 = val;
        FA.curIm.kappa1 = FA.kappa1;
        
    case 'e_kappa2'
        if isempty(val)
            set(hObject, 'String', FA.kappa2);
            errordlg('Kappa2 must be a number', 'Error');
            return
        end
        FA.kappa2 = val;
        FA.curIm.kappa2 = FA.kappa2;
        
    case 'e_fiberIntensity'
        if isempty(val)
            set(hObject, 'String', FA.fiberIntensity);
            errordlg('Fiber intensity must be a number', 'Error');
            return
        end
        FA.fiberIntensity = round(val);
        FA.curIm.fiberIntensity = FA.fiberIntensity;
        
    case 'e_iterations'
        if isempty(val) || val < 0
            set(hObject, 'String', FA.iterations);
            errordlg('Number of iterations must be a nonnegative number', 'Error');
            return
        end
        FA.iterations = round(val);
end

function FiberTrackingParameters_SetFiberIntensity(hObject, eventdata)
FA = guidata(gcf);
if isempty(FA.name); return; end
[x, y] = FA.getPoint;

% If only right click occurs
if isempty(x); return; end

% Get intensity of the image at this point and set it to the field
FA.fiberIntensity = double(FA.im(y, x));
FA.curIm.fiberIntensity = FA.fiberIntensity;

function FiberTrackingParameters_Step(hObject, eventdata)
FA = guidata(hObject);
val = sscanf(get(hObject, 'String'), '%f', 1);
% Save old values of steps
step_old = FA.step;
step_nm_old = FA.step_nm;

switch get(hObject, 'Tag')
    case 'e_step'
        if isempty(val) || val <= 0
            set(hObject, 'String', FA.step);
            errordlg('Step must be a positive number', 'Error');
            return
        end
        FA.step = val;
        FA.step_nm = val*FA.scaleXY;
        
    case 'e_step_nm'
        if isempty(val) || val <= 0
            set(hObject, 'String', FA.step_nm);
            errordlg('Step (nm) must be a positive number', 'Error');
            return
        end
        FA.step_nm = val;
        FA.step = val/FA.scaleXY;
end
FA.curIm.step = FA.step;

% If image already contains some tracked fibers
if ~isempty(FA.curIm.xy)
    switch questdlg('Refit all previously tracked fibers with the new step?', ...
        'FiberApp', 'Yes', 'No', 'No')
    case 'Yes'
        FiberAppGUI.FitAllFibers(hObject, eventdata);
    case {'No', ''}
        % Restore old step values
        FA.step = step_old;
        FA.step_nm = step_nm_old;
        FA.curIm.step = step_old;
    end
end

function FiberTrackingParameters_AutoFit(hObject, eventdata)
FA = guidata(hObject);
FA.autoFit = (get(hObject, 'Value') == get(hObject, 'Max'));

function FiberTrackingParameters_AStar(hObject, eventdata)
FA = guidata(hObject);
FA.aStar = (get(hObject, 'Value') == get(hObject, 'Max'));

