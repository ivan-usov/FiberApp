% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function p = OrientationDistribution
ph = 122; % panel height
% Panel and hide button
p = uipanel(gcf, 'Units', 'pixels', 'FontWeight', 'bold', ...
    'BorderType', 'line', 'HighlightColor', [0.5 0.5 0.5], ...
    'Visible', 'off', ...
    'Title', 'Orientation Distribution', ...
    'Tag', 'OrientationDistribution', ...
    'Position', [-231 1 230 ph]);
uicontrol(p, 'Style', 'pushbutton', 'String', '-', ...
    'Tag', 'OrientationDistribution', ...
    'Callback', @panel.hide, ...
    'Position', [211 ph-25 18 16]);
% Panel components --------------------------------------------------------
% Angle step
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Angle step:', ...
    'Position', [10 ph-38 130 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'deg', ...
    'Position', [188 ph-38 35 14]);
ui.angleStep = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 5, ...
    'Position', [135 ph-42 51 22]);
% Polar coordinates
ui.polarCoord = uicontrol(p, 'Style', 'checkbox', 'Value', 1, ...
    'String', 'Polar coordinates', ...
    'Position', [10 ph-65 120 22]);
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Callback', @HeightDistribution_toSave, ...
    'Position', [10 ph-88 114 20]);
% --- raw data
ui.rawData = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'Enable', 'off', ...
    'String', 'raw data', ...
    'Position', [15 ph-111 100 20]);
% Plot button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Plot', ...
    'Callback', @OrientationDistribution_Plot, ...
    'Position', [135 ph-112 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function HeightDistribution_toSave(hObject, eventdata)
ui = get(get(hObject, 'Parent'), 'UserData');
if (get(hObject, 'Value') == get(hObject, 'Max'))
    set(ui.rawData, 'Enable', 'on');
else
    set(ui.rawData, 'Enable', 'off');
end

function OrientationDistribution_Plot(hObject, eventdata)
% Handle to the application data
FA = guidata(gcf);

% Check for the data presence
if sum(cellfun(@length, {FA.imageData.xy})) == 0
    msgbox('Empty data');
    return
end

% Orientation distribution works only with a single image
if length(FA.imageData) > 1
    [sel, ok] = listdlg(...
        'Name', 'Orientation Distribution', ...
        'PromptString', {'Orientation Distribution works only with data from a single image.', ...
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

% Get parameters from the panel GUI elements
ui = get(get(hObject, 'Parent'), 'UserData');
angleStep = abs(sscanf(get(ui.angleStep, 'String'), '%f', 1));
polarCoord = (get(ui.polarCoord, 'Value') == get(ui.polarCoord, 'Max'));
toSave = (get(ui.toSave, 'Value') == get(ui.toSave, 'Max'));
rawData = (get(ui.rawData, 'Value') == get(ui.rawData, 'Max'));

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

% Proceed with the selected data
vect = cellfun(@get_vectors, FA.imageData(sel).xy, 'UniformOutput', false);
vect = [vect{:}]; % unite data of all fibrils

% Calculate 2D order parameter (S)
A = sum(vect(1,:).^2);
B = sum(prod(vect));
N = size(vect, 2);
S = sqrt((2*A-N)^2+4*B^2)/N;

% Calculate orientation distribution
vect(:, vect(2,:)>0) = - vect(:, vect(2,:)>0); % Turn the coordinate system from informatics into geometrical 
orientation = acos(vect(1,:));

% Check angleStep value
if isempty(angleStep) || isnan(angleStep) || isinf(angleStep) || angleStep <= 0
    % set default value
    angleStep = 5;
end
stepNum = round(180/angleStep);
angleStep = 180/stepNum;
set(ui.angleStep, 'String', angleStep);

% Calculate for 0-pi range
n = histc(orientation, linspace(0, pi, stepNum+1));
n(1) = n(1) + n(end);
n(end) = []; % remove orientation = pi values

% Plot distribution in a new figure
figure('NumberTitle', 'off', 'Name', ['ODist ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
title(FA.dataName, 'Interpreter', 'none');
if polarCoord % according to the selected coordinate system
    % Reflect through the origin to the full 360 deg range
    step = pi*angleStep/180; % angle step in rad
    centers = - step/2 + linspace(0, 2*pi, 2*stepNum+1) ;
    n = [n(end), n, n];
    polar(centers, n);
    text('Units', 'normalized', 'Position', [-0.09 0.16], ...
        'BackgroundColor', [1 1 1], ...
        'String', ['S_{2D} = ' num2str(S, 2)]);
    centers = 180*centers/pi; % recalculate into deg in case of saving to a text file
else
    centers = [-angleStep/2, linspace(0, 180, stepNum+1) + angleStep/2]; % in deg
    n = [n(end), n, n(1)];
    plot(centers, n);
    xlim([0 180]);
    xlabel('Angle, \theta (deg)');
    ylabel('Number of vectors, n_v');
    text('Units', 'normalized', 'Position', [0.8 0.95], ...
        'BackgroundColor', [1 1 1], ...
        'String', ['S_{2D} = ' num2str(S, 2)]);
end

% Save results to a text file
if toSave
    if rawData
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['ORaw_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\r\n', 'Angle, \theta');	% Long name
            fprintf(fileID, '%s\r\n', 'deg');           % Units
            fprintf(fileID, '%s\r\n', '');              % Comments
            fprintf(fileID, '%g\r\n', orientation);            % Data
            
            fclose(fileID);
        end
        
    else
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['ODist_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\t%s\r\n', ...
                'Angle, \theta', 'Number of vectors, n_v');	% Long name
            fprintf(fileID, '%s\t%s\r\n', 'deg', '');       % Units
            fprintf(fileID, '%s\t%s\r\n', '', '');          % Comments
            fprintf(fileID, '%g\t%u\r\n', [centers; n]);    % Data
            
            fclose(fileID);
        end
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Plot');

function v = get_vectors(xy)
v = diff(xy, 1, 2);
l = sqrt(sum(v.^2));
v = v./[l; l];

