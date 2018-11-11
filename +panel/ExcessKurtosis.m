%EXCESSKURTOSIS Create an excess kurtosis panel

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function p = ExcessKurtosis
ph = 76; % panel height
pTitle = 'Excess Kurtosis';
pTag = 'ExcessKurtosis';
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
% Processing length
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Processing length:', ...
    'Position', [10 ph-38 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-38 35 14]);
ui.procLength = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'auto', ...
    'Position', [135 ph-42 51 22]);
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Position', [10 ph-65 120 20]);
% Calculate button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Calculate', ...
    'Callback', @ExcessKurtosis_Calculate, ...
    'Position', [135 ph-66 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function ExcessKurtosis_Calculate(hObject, eventdata)
% Handle to the application data
FA = guidata(gcf);

% Check for the data presence
if sum(cellfun(@length, {FA.imageData.xy})) == 0
    msgbox('Empty data');
    return
end

% Get parameters from the panel GUI elements
ui = get(get(hObject, 'Parent'), 'UserData');
procLength = sscanf(get(ui.procLength, 'String'), '%f', 1);
toSave = (get(ui.toSave, 'Value') == get(ui.toSave, 'Max'));

% Get uniformly distributed data of fibers in nm
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

% Max processing length
maxStepNum = max(cellfun(@length, data)) - 1;

% Check procLength value
if isempty(procLength) || isnan(procLength) || procLength < 3*step
    % set auto value
    procStepNum = round(maxStepNum/2);
else
    % round procLength to an integer number of steps, but < than maxStepNum
    procStepNum = min([round(procLength/step), maxStepNum]);
end
procLength = procStepNum*step;
set(ui.procLength, 'String', procLength);

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

xdata = step*(1:procStepNum);
ydata2 = zeros(1, procStepNum); % \theta(s)^2
ydata4 = zeros(1, procStepNum); % \theta(s)^4
count = zeros(1, procStepNum); % weight for each graph point
for k = 1:length(data)
    % Normalized vectors
    vect = diff(data{k}, 1, 2);
    leng = sqrt(sum(vect.^2));
    vect = vect./[leng; leng]; % normalized vectors
    
    n = length(vect); % number of vectors in the current fiber
    
    shiftNum = min(procStepNum, n-1);
    
    count(1:shiftNum) = count(1:shiftNum) + (n-1:-1:n-shiftNum);
    
    % Cycle for different separations between vectors along a fiber
    for l = 1:shiftNum
        temp = real( acos( sum( vect(:,1:end-l) .* vect(:,1+l:end) ) ) ).^2;
        ydata2(l) = ydata2(l) + sum(temp);
        ydata4(l) = ydata4(l) + sum(temp.^2);
    end
end

% Excess Kurtosis
ydata = (ydata4./count)./((ydata2./count).^2)-3;

% Plot graph in a new figure
figure('NumberTitle', 'off', 'Name', ['EK ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
plot(xdata, ydata);
xlabel('Separation, l (nm)');
ylabel('Excess Kurtosis, \langle\theta^4\rangle/\langle\theta^2\rangle^2-3');
title(FA.dataName, 'Interpreter', 'none');

% Save results to a text file
if toSave
    [fileName, filePath] = uiputfile('*.txt', ...
        'Save As', ['EK_' FA.dataName(1:end-4) '.txt']);
    if fileName ~= 0
        % Save data
        fileID = fopen(fullfile(filePath, fileName), 'w');
        
        fprintf(fileID, '%s\t%s\t%s\r\n', ...
            'Separation, l', 'Excess Kurtosis', 'Weight');          % Long name
        fprintf(fileID, '%s\t%s\t%s\r\n', 'nm', '', '');            % Units
        fprintf(fileID, '%s\t%s\t%s\r\n', '', '', '');              % Comments
        fprintf(fileID, '%g\t%f\t%g\r\n', [xdata; ydata; count]);   % Data
        
        fclose(fileID);
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Calculate');
