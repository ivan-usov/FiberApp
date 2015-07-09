% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function p = OrderParameter2D
ph = 277; % panel height
% Panel and hide button
p = uipanel(gcf, 'Units', 'pixels', 'FontWeight', 'bold', ...
    'BorderType', 'line', 'HighlightColor', [0.5 0.5 0.5], ...
    'Visible', 'off', ...
    'Title', 'Order Parameter 2D', ...
    'Tag', 'OrderParameter2D', ...
    'Position', [-231 1 230 ph]);
uicontrol(p, 'Style', 'pushbutton', 'String', '-', ...
    'Tag', 'OrderParameter2D', ...
    'Callback', @panel.hide, ...
    'Position', [211 ph-25 18 16]);
% Panel components --------------------------------------------------------
% Fitting equations
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'y = a·S_align + (1 - a)·S_rand', ...
    'Position', [10 ph-38 210 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'S_align = b + (1 - b)·exp[ -x / (2L) ]', ...
    'Position', [10 ph-55 210 14]);
% Processing area
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Processing area', ...
    'Position', [10 ph-78 100 14]);
% --- x
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'x:', ...
    'Position', [15 ph-101 40 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-101 35 14]);
ui.xMin = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'auto', ...
    'Position', [85 ph-105 51 22]);
ui.xMax = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'auto', ...
    'Position', [135 ph-105 51 22]);
% --- y (inv)
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'y (inv):', ...
    'Position', [15 ph-124 40 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-124 35 14]);
ui.yMin = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'auto', ...
    'Position', [85 ph-128 51 22]);
ui.yMax = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'auto', ...
    'Position', [135 ph-128 51 22]);
% --- button
uicontrol(p, 'Style', 'pushbutton', ...
    'Callback', @OrderParameter2D_SelectProcAreaRect, ...
    'Position', [65 ph-116 20 20]);
% --- fiber length density
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'fiber length density:', ...
    'Position', [15 ph-147 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', '1/um', ...
    'Position', [188 ph-147 35 14]);
ui.fibLengthDensity = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'Callback', @OrderParameter2D_FibLengthDensity, ...
    'Position', [135 ph-151 51 22]);
% Grid step
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Grid step:', ...
    'Position', [10 ph-170 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-170 35 14]);
ui.gridStep = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'auto', ...
    'Position', [135 ph-174 51 22]);
% Processing length
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Processing length:', ...
    'Position', [10 ph-193 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-193 35 14]);
ui.procLength = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'auto', ...
    'Position', [135 ph-197 51 22]);
% Random images
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Random images:', ...
    'Position', [10 ph-216 130 14]);
ui.randImNum = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 10, ...
    'Position', [135 ph-220 51 22]);
% Circle area
ui.isCircleArea = uicontrol(p, 'Style', 'checkbox', 'Value', 1, ...
    'String', 'Circle area', ...
    'Position', [10 ph-243 82 22]);
% Fit data
ui.isFitData = uicontrol(p, 'Style', 'checkbox', 'Value', 1, ...
    'String', 'Fit data', ...
    'Position', [135 ph-243 82 22]);
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Position', [10 ph-266 120 22]);
% Calculate button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Calculate', ...
    'Callback', @OrderParameter2D_Calculate, ...
    'Position', [135 ph-267 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function OrderParameter2D_SelectProcAreaRect(hObject, eventdata)
FA = guidata(gcf);

if ~isempty(FA.curIm)
    rect = getrect(gca)*FA.scaleXY;
    ui = get(get(hObject, 'Parent'), 'UserData');
    set(ui.xMin, 'String', rect(1));
    set(ui.xMax, 'String', rect(1) + rect(3));
    set(ui.yMin, 'String', rect(2));
    set(ui.yMax, 'String', rect(2) + rect(4));
end

function OrderParameter2D_FibLengthDensity(hObject, eventdata)
fibLengthDensity = get(hObject, 'UserData');
set(hObject, 'String', fibLengthDensity);
errordlg('Access denied');

function OrderParameter2D_Calculate(hObject, eventdata)
% Handle to the application data
FA = guidata(gcf);

% Check for the data presence
if sum(cellfun(@length, {FA.imageData.xy})) == 0
    msgbox('Empty data');
    return
end

% Order parameter 2D works only with a single image
if length(FA.imageData) > 1
    [sel, ok] = listdlg(...
        'Name', 'Order Parameter 2D', ...
        'PromptString', {'Order Parameter 2D works only with data from a single image.', ...
        'Choose one to proceed:', ''}, ...
        'ListString' , {FA.imageData.name}, ...
        'SelectionMode', 'single', ...
        'ListSize', [170 100]);
    if ~ok || isempty(sel)
        return
    end
else
    sel = 1;
end

% Get parameters from the panel for calculation
ui = get(get(hObject, 'Parent'), 'UserData');
% Shift between an image and data = 0.5
xMin = sscanf(get(ui.xMin, 'String'), '%f', 1) - 0.5;
xMax = sscanf(get(ui.xMax, 'String'), '%f', 1) - 0.5;
yMin = sscanf(get(ui.yMin, 'String'), '%f', 1) - 0.5;
yMax = sscanf(get(ui.yMax, 'String'), '%f', 1) - 0.5;
gridStep = sscanf(get(ui.gridStep, 'String'), '%f', 1);
procLength = sscanf(get(ui.procLength, 'String'), '%f', 1);
randImNum = abs(sscanf(get(ui.randImNum, 'String'), '%d', 1));
isCircleArea = get(ui.isCircleArea, 'Value') == get(ui.isCircleArea, 'Max');
isFitData = get(ui.isFitData, 'Value') == get(ui.isFitData, 'Max');
toSave = (get(ui.toSave, 'Value') == get(ui.toSave, 'Max'));

% Process selected data
step = FA.imageData(sel).step_nm;
xy = FA.imageData(sel).xy_nm;

% Check processing area values
p_all = cellfun(@get_points, xy, 'UniformOutput', false);
p_all = [p_all{:}]; % combine points of all fibers
[xMin, xMax] = utility.checkRange(xMin, xMax, p_all(1,:));
[yMin, yMax] = utility.checkRange(yMin, yMax, p_all(2,:));
set(ui.xMin, 'String', xMin+0.5);
set(ui.xMax, 'String', xMax+0.5);
set(ui.yMin, 'String', yMin+0.5);
set(ui.yMax, 'String', yMax+0.5);

% Check gridStep value
if isempty(gridStep) || isnan(gridStep) || gridStep <= step
    % set default value
    gridStep = 10*step;
end
set(ui.gridStep, 'String', gridStep);

% Image size in grid steps (cells)
numCellX = floor((xMax-xMin)/gridStep);
numCellY = floor((yMax-yMin)/gridStep);

% Check procLength and values
if isempty(procLength) || isnan(procLength) || procLength <= gridStep
    % set auto value
    procStepNum = min([numCellX, numCellY]);
else
    % round procLength to an integer number of graphSteps
    procStepNum = min([round(procLength/gridStep), numCellX, numCellY]);
end
procLength = procStepNum*gridStep;
set(ui.procLength, 'String', procLength);

% Pick data within the range
% p_im - coordinates of vectors' start points
% v_im - vector coordinates
xy_im = cellfun(@(xy)get_points_in_range(xy, xMin, xMax, yMin, yMax), xy, ...
    'UniformOutput', false);
xy_im = [xy_im{:}];

p_im = cellfun(@get_points, xy_im, 'UniformOutput', false);
v_im = cellfun(@get_vectors, xy_im, 'UniformOutput', false);
p_im = [p_im{:}];
v_im = [v_im{:}];

% Check for a presence of vectors in the processing area
if isempty(p_im);
    warndlg('There are no fibers in the selected area');
    return
end

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

% Calculate fiber length density (in 1/um)
fibLengthDensity = 1000*size(p_im, 2)*step/((xMax-xMin)*(yMax-yMin));
set(ui.fibLengthDensity, 'String', fibLengthDensity, 'UserData', fibLengthDensity);

% Calculate Order Parameter 2D vs Box size
[xdata, S_im] = algorithm.OP2D(p_im, v_im, xMin, yMin, ...
    gridStep, procStepNum, numCellX, numCellY, isCircleArea);

% Generate images with random fibers positioning
S_rand = zeros(randImNum, length(xdata));
for l = 1:randImNum
    xc = random('Uniform', xMin, xMax, size(xy_im));
    yc = random('Uniform', yMin, yMax, size(xy_im));
    angle = random('Uniform', 0, 2*pi, size(xy_im));
    
    [p_rand, v_rand] = arrayfun(@move_and_rotate, xy_im, xc, yc, angle, ...
        'UniformOutput', false);
    
    % Unite points and vectors of all fibers
    p_rand = [p_rand{:}];
    v_rand = [v_rand{:}];
    
    % Periodic boundary conditions
    p_rand(1,:) = mod(p_rand(1,:)-xMin, xMax-xMin) + xMin;
    p_rand(2,:) = mod(p_rand(2,:)-yMin, yMax-yMin) + yMin;
    
    [~, S_rand(l,:)] = algorithm.OP2D(p_rand, v_rand, ...
        xMin, yMin, gridStep, procStepNum, numCellX, numCellY, isCircleArea);
end
% Average S_rand
S_rand = mean(S_rand);

% Plot the graph in a new figure
figure('NumberTitle', 'off', 'Name', ['OP2D ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
plot(xdata, S_im, '.', xdata, S_rand, '.');
legend('S_{im}', 'S_{rand}');

% Fit data
if isFitData
    fun = @(x) sum((S_im - (1-x(1)).*S_rand - x(1).*((1-x(2)).*exp(-xdata./(2.*x(3)))+x(2))).^2);
    [res, ~, exfl] = fminsearch(fun, [0.6, 0.1, 100]);
    if exfl == 1
        fit_y = (1-res(1)).*S_rand + res(1).*((1-res(2)).*exp(-xdata./(2.*res(3)))+res(2));
        plot(xdata, S_im, '.', xdata, S_rand, '.', [0, xdata], [1, fit_y]);
        legend('S_{im}', 'S_{rand}', 'Fit', 'Location', 'North');
        text('Units', 'normalized', 'Position', [0.7 0.9], ...
            'BackgroundColor', [1 1 1], ...
            'String', {
            ['a = ' num2str(res(1), '%.3f')];
            ['b = ' num2str(res(2), '%.3f')];
            ['\lambda = ' num2str(res(3), '%.2f') ' nm']});
    else
        text('Units', 'normalized', 'Position', [0.7 0.9], ...
            'BackgroundColor', [1 1 1], ...
            'String', 'Fit did not converge');
        legend('Location', 'North');
    end
end

xlabel('Box size, d (nm)');
ylabel('Order parameter 2D, S_{2D}');
title(FA.dataName, 'Interpreter', 'none');

% Save results to a text file
if toSave
    [fileName, filePath] = uiputfile('*.txt', ...
        'Save As', ['OP2D_' FA.dataName(1:end-4) '.txt']);
    if fileName ~= 0
        % Save data
        fileID = fopen(fullfile(filePath, fileName), 'w');
        
        fprintf(fileID, '%s\t%s\t%s\r\n', ...
            'Box size, d', 'Image OP, S_{im}', 'Random OP, S_{rand}');	% Long name
        fprintf(fileID, '%s\t%s\t%s\r\n', 'nm', '', '');                % Units
        fprintf(fileID, '%s\t%s\t%s\r\n', '', '', '');                  % Comments
        fprintf(fileID, '%g\t%f\t%f\r\n', [xdata; S_im; S_rand]);       % Data
        
        fclose(fileID);
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Calculate');

function p = get_points_in_range(xy, xMin, xMax, yMin, yMax)
ind = diff([0, xMin <= xy(1,:) & xy(1,:) <= xMax & yMin <= xy(2,:) & xy(2,:) <= yMax, 0]);
in = find(ind == 1);
out = find(ind == -1);
p = cell(1, length(in));
for l = 1:length(in)
    p{l} = xy(:, in(l):out(l)-1);
end

function p = get_points(xy)
p = xy(:,1:end-1);

function v = get_vectors(xy)
v = diff(xy, 1, 2);
l = sqrt(sum(v.^2));
v = v./[l; l];

function [p_rand, v_rand] = move_and_rotate(xy, xc, yc, angle)
xy = xy{1};

% Center at (0; 0)
xy = bsxfun(@minus, xy, xy(:,1));

% Move to (xc; yc) and turn by angle
p_rand = [xc + xy(1,:).*cos(angle) - xy(2,:).*sin(angle);
    yc + xy(1,:).*sin(angle) + xy(2,:).*cos(angle)];

% Get vectors and points
v_rand = diff(xy, 1, 2);
l = sqrt(sum(v_rand.^2));
v_rand = v_rand./[l; l];

p_rand = p_rand(:,1:end-1);

