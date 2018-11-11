%CURVATUREDISTRIBUTION Create a curvature distribution panel

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function p = CurvatureDistribution
ph = 168; % panel height
pTitle = 'Curvature Distribution';
pTag = 'CurvatureDistribution';
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
    'Position', [211 ph-30 18 16]);
% Panel components --------------------------------------------------------
% Range
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Range:', ...
    'Position', [10 ph-38 50 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', '1/nm', ...
    'Position', [188 ph-38 35 14]);
ui.rMin = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'auto', ...
    'Position', [85 ph-42 51 22]);
ui.rMax = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'auto', ...
    'Position', [135 ph-42 51 22]);
% Number of bins
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Number of bins:', ...
    'Position', [10 ph-61 80 14]);
ui.numBins = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 30, ...
    'Position', [135 ph-65 51 22]);
% Vector separation
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Vector separation:', ...
    'Position', [10 ph-84 120 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'steps', ...
    'Position', [188 ph-84 35 14]);
ui.vectSep = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 2, ...
    'Position', [135 ph-88 51 22]);
% Absolute curvature values
ui.absVal = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Absolute curvature values', ...
    'Position', [10 ph-111 150 20]);
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Callback', @HeightDistribution_toSave, ...
    'Position', [10 ph-134 114 20]);
% --- raw data
ui.rawData = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'Enable', 'off', ...
    'String', 'raw data', ...
    'Position', [15 ph-157 100 20]);
% Plot button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Plot', ...
    'Callback', @CurvatureDistribution_Plot, ...
    'Position', [135 ph-158 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function HeightDistribution_toSave(hObject, eventdata)
ui = get(get(hObject, 'Parent'), 'UserData');
if (get(hObject, 'Value') == get(hObject, 'Max'))
    set(ui.rawData, 'Enable', 'on');
else
    set(ui.rawData, 'Enable', 'off');
end

function CurvatureDistribution_Plot(hObject, eventdata)
% Handle to the application data
FA = guidata(gcf);

% Check for the data presence
if sum(cellfun(@length, {FA.imageData.xy})) == 0
    msgbox('Empty data');
    return
end

% Get parameters from the panel GUI elements
ui = get(get(hObject, 'Parent'), 'UserData');
rMin = sscanf(get(ui.rMin, 'String'), '%f', 1);
rMax = sscanf(get(ui.rMax, 'String'), '%f', 1);
numBins = abs(sscanf(get(ui.numBins, 'String'), '%d', 1));
vectSep = abs(sscanf(get(ui.vectSep, 'String'), '%d', 1));
absVal = (get(ui.absVal, 'Value') == get(ui.absVal, 'Max'));
toSave = (get(ui.toSave, 'Value') == get(ui.toSave, 'Max'));
rawData = (get(ui.rawData, 'Value') == get(ui.rawData, 'Max'));

% Get uniformly distributed XY data of fibers in nm
step = min([FA.imageData.step_nm]);
data = {FA.imageData.xy_nm};
for k = 1:length(FA.imageData)
    if FA.imageData(k).step_nm ~= step
        % Uniformly distribute points (in nm) among all fibers
        data{k} = cellfun(@(xy) utility.distributePoints(xy, step), data{k}, ...
            'UniformOutput', false);
    end
end
data = [data{:}]; % unite data of all images

% Check smoothing parameter
if isempty(vectSep) || isnan(vectSep) || isinf(vectSep) || vectSep <= 0
    % set default value
    vectSep = 2;
end
set(ui.vectSep, 'String', vectSep);

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

curvature = cellfun(@(xy)curvature_calc(xy, step, vectSep), data, ...
            'UniformOutput', false);
curvature = [curvature{:}]; % unite curvature of all fibrils

% Set absolute values if "Absolute curvature values" is checked
if absVal; curvature = abs(curvature); end

% Check numBins value
if isempty(numBins) || isnan(numBins) || isinf(numBins) || numBins <= 0
    % set default value
    numBins = 30;
end
set(ui.numBins, 'String', numBins);

% Check rangeMin and rangeMax values
[rMin, rMax] = utility.checkRange(rMin, rMax, curvature);
set(ui.rMin, 'String', rMin);
set(ui.rMax, 'String', rMax);

edges = linspace(rMin, rMax, numBins+1);
n = histc(curvature, edges);
n(end) = []; % remove curvature = rangeMax values
centers = (edges(1:end-1)+edges(2:end))/2;

% Plot distribution in a new figure
figure('NumberTitle', 'off', 'Name', ['CDist ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
bar(centers, n, 'hist');
xlim([rMin rMax]); % set the correct limits
xlabel('Local curvature, 1/R_{c} (1/nm)');
ylabel('Number of counts, n_c');
title(FA.dataName, 'Interpreter', 'none');

% Save results to a text file
if toSave
    if rawData
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['CRaw_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\r\n', 'Local curvature, 1/R_{c}');	% Long name
            fprintf(fileID, '%s\r\n', '1/nm');                      % Units
            fprintf(fileID, '%s\r\n', '');                          % Comments
            fprintf(fileID, '%f\r\n', curvature);                   % Data
            
            fclose(fileID);
        end
        
    else
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['CDist_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\t%s\r\n', ...
                'Local curvature, 1/R_{c}', 'Number of counts, n_c');	% Long name
            fprintf(fileID, '%s\t%s\r\n', '1/nm', '');                  % Units
            fprintf(fileID, '%s\t%s\r\n', '', '');                      % Comments
            fprintf(fileID, '%f\t%u\r\n', [centers; n]);                % Data
            
            fclose(fileID);
        end
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Plot');

function curvature = curvature_calc(xy, step, vectSep)
% First derivative
v = diff(xy, 1, 2);
l = sqrt(sum(v.^2)); % vectors length
v = v./[l; l]; % normalize

v12 = v(:, 1:end-vectSep);
v23 = v(:, 1+vectSep:end);

% Second derivative
vect = v23 - v12;
leng = step*vectSep;
vect = vect./leng;

% Curvature sign
v13 = v12 + v23;
s = sign(v12(1,:).*v13(2,:) - v12(2,:).*v13(1,:));

% Resulting curvature
curvature = sqrt(sum(vect.^2)).*s;
