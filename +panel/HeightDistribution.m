function p = HeightDistribution
ph = 145; % panel height
pTitle = 'Height Distribution';
pTag = 'HeightDistribution';
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
% Average height for each fiber
ui.average = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Average height for each fiber', ...
    'Position', [10 ph-88 200 20]);
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Callback', @HeightDistribution_toSave, ...
    'Position', [10 ph-111 114 20]);
% --- raw data
ui.rawData = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'Enable', 'off', ...
    'String', 'raw data', ...
    'Position', [15 ph-134 100 20]);
% Plot button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Plot', ...
    'Callback', @HeightDistribution_Plot, ...
    'Position', [135 ph-135 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function HeightDistribution_toSave(hObject, eventdata)
ui = get(get(hObject, 'Parent'), 'UserData');
if (get(hObject, 'Value') == get(hObject, 'Max'))
    set(ui.rawData, 'Enable', 'on');
else
    set(ui.rawData, 'Enable', 'off');
end

function HeightDistribution_Plot(hObject, eventdata)
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
average = (get(ui.average, 'Value') == get(ui.average, 'Max'));
toSave = (get(ui.toSave, 'Value') == get(ui.toSave, 'Max'));
rawData = (get(ui.rawData, 'Value') == get(ui.rawData, 'Max'));

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

% Get height data of the fibers
if average
    fibHeight = [FA.imageData(:).height_nm];
else % Use all height values
    % Get uniformly distributed data of fibers in nm
    step = min([FA.imageData.step_nm]);
    fibHeight = {FA.imageData.z_nm};
    for k = 1:length(FA.imageData)
        data_step = FA.imageData(k).step_nm;
        if data_step ~= step
            len = FA.imageData(k).length_nm;
            num = floor(len/step);
            tail = (len - num*step)/2;
            for l = 1:length(fibHeight{k})
                z = fibHeight{k}{l};
                fibHeight{k}{l} = interp1(data_step*(0:length(z)-1), z, ...
                    step*(0:num(l))+tail(l), 'spline');
            end
        end
    end
    fibHeight = [fibHeight{:}]; % unite data of all images
    fibHeight = [fibHeight{:}]; % unite data of all fibrils
end

% Check numBins value
if isempty(numBins) || isnan(numBins) || isinf(numBins) || numBins <= 0
    % set default value
    numBins = 30;
end
set(ui.numBins, 'String', numBins);

% Check rangeMin and rangeMax values
[rMin, rMax] = utility.checkRange(rMin, rMax, fibHeight);
set(ui.rMin, 'String', rMin);
set(ui.rMax, 'String', rMax);

edges = linspace(rMin, rMax, numBins+1);
n = histc(fibHeight, edges);
n(end) = []; % remove data = rangeMax values
centers = (edges(1:end-1)+edges(2:end))/2;

% Plot distribution in a new figure
figure('NumberTitle', 'off');
bar(centers, n, 'hist');
xlim([rMin, rMax]); % set the correct limits
title(FA.dataName, 'Interpreter', 'none');

if average
    xlabel('Average height, \langleh\rangle (nm)');
    ylabel('Number of fibers, n_f');
    set(gcf, 'Name', ['HDistAv ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
    text('Units', 'normalized', 'Position', [0.75 0.92], ...
        'BackgroundColor', [1 1 1], ...
        'String', {['\langleH\rangle = ' num2str(mean(fibHeight), '%.2f') ' nm']; ...
        ['\sigma_H = ' num2str(std(fibHeight), '%.2f') ' nm']});
else
    xlabel('Height, h (nm)');
    ylabel('Number of points, n_p');
    set(gcf, 'Name', ['HDist ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
    text('Units', 'normalized', 'Position', [0.75 0.92], ...
        'BackgroundColor', [1 1 1], ...
        'String', {['\langleh\rangle = ' num2str(mean(fibHeight), '%.2f') ' nm']; ...
        ['\sigma_h = ' num2str(std(fibHeight), '%.2f') ' nm']});
end

% Save results to a text file
if toSave
    if average && rawData
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['HAvRaw_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\r\n', 'Average height, <h>');	% Long name
            fprintf(fileID, '%s\r\n', 'nm');                    % Units
            fprintf(fileID, '%s\r\n', '');                      % Comments
            fprintf(fileID, '%g\r\n', fibHeight);               % Data
            
            fclose(fileID);
        end
        
    elseif average && ~rawData
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['HDistAv_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\t%s\r\n', ...
                'Average height, <h>', 'Number of fibers, n_f');	% Long name
            fprintf(fileID, '%s\t%s\r\n', 'nm', '');                % Units
            fprintf(fileID, '%s\t%s\r\n', '', '');                  % Comments
            fprintf(fileID, '%g\t%u\r\n', [centers; n]);            % Data
            
            fclose(fileID);
        end
        
    elseif ~average && rawData
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['HRaw_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\r\n', 'Height, h');	% Long name
            fprintf(fileID, '%s\r\n', 'nm');        % Units
            fprintf(fileID, '%s\r\n', '');          % Comments
            fprintf(fileID, '%g\r\n', fibHeight);        % Data
            
            fclose(fileID);
        end
        
    elseif ~average && ~rawData
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['HDist_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            fprintf(fileID, '%s\t%s\r\n', ...
                'Height, h', 'Number of points, n_p');      % Long name
            fprintf(fileID, '%s\t%s\r\n', 'nm', '');        % Units
            fprintf(fileID, '%s\t%s\r\n', '', '');          % Comments
            fprintf(fileID, '%g\t%u\r\n', [centers; n]);	% Data
            
            fclose(fileID);
        end
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Plot');

