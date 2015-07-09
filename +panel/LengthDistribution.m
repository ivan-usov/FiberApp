% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function p = LengthDistribution
ph = 122; % panel height
% Panel and hide button
p = uipanel(gcf, 'Units', 'pixels', 'FontWeight', 'bold', ...
    'BorderType', 'line', 'HighlightColor', [0.5 0.5 0.5], ...
    'Visible', 'off', ...
    'Title', 'Length Distribution', ...
    'Tag', 'LengthDistribution', ...
    'Position', [-231 1 230 ph]);
uicontrol(p, 'Style', 'pushbutton', 'String', '-', ...
    'Tag', 'LengthDistribution', ...
    'Callback', @panel.hide, ...
    'Position', [211 ph-25 18 16]);
% Panel components --------------------------------------------------------
% Range
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Range:', ...
    'Position', [10 ph-38 50 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
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
    'Callback', @LengthDistribution_Plot, ...
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

function LengthDistribution_Plot(hObject, eventdata)
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
numBins = sscanf(get(ui.numBins, 'String'), '%d', 1);
toSave = (get(ui.toSave, 'Value') == get(ui.toSave, 'Max'));
rawData = (get(ui.rawData, 'Value') == get(ui.rawData, 'Max'));

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

% Get length data of the fibers
FA = guidata(hObject);
fibLen = [FA.imageData(:).length_nm];

% Check numBins value
if isempty(numBins) || isnan(numBins) || isinf(numBins) || numBins <= 0
    % set default value
    numBins = 30;
end
set(ui.numBins, 'String', numBins);

% Check rangeMin and rangeMax values
[rMin, rMax] = utility.checkRange(rMin, rMax, fibLen);
set(ui.rMin, 'String', rMin);
set(ui.rMax, 'String', rMax);

edges = linspace(rMin, rMax, numBins+1);
n = histc(fibLen, edges);
n(end) = []; % remove data = rangeMax values
centers = (edges(1:end-1)+edges(2:end))/2;

% Plot distribution in a new figure
figure('NumberTitle', 'off', 'Name', ['LDist ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
bar(centers, n, 'hist');
xlim([rMin, rMax]); % set the correct limits
xlabel('Contour length, L (nm)');
ylabel('Number of fibers, n_f');
title(FA.dataName, 'Interpreter', 'none');
text('Units', 'normalized', 'Position', [0.75 0.92], ...
        'BackgroundColor', [1 1 1], ...
        'String', {['\langleL\rangle = ' num2str(mean(fibLen), '%.2f') ' nm']; ...
        ['\sigma_L = ' num2str(std(fibLen), '%.2f') ' nm']});
    
% Save results to a text file
if toSave
    if rawData
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['LRaw_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\r\n', 'Contour length, L');	% Long name
            fprintf(fileID, '%s\r\n', 'nm');                % Units
            fprintf(fileID, '%s\r\n', '');                  % Comments
            fprintf(fileID, '%g\r\n', fibLen);                % Data
            
            fclose(fileID);
        end
        
    else
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['LDist_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\t%s\r\n', ...
                'Contour length, L', 'Number of fibers, n_f');	% Long name
            fprintf(fileID, '%s\t%s\r\n', 'nm', '');            % Units
            fprintf(fileID, '%s\t%s\r\n', '', '');              % Comments
            fprintf(fileID, '%g\t%u\r\n', [centers; n]);        % Data
            
            fclose(fileID);
        end
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Plot');

