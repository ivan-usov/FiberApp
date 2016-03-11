function p = ScalingExponent
ph = 99; % panel height
pTitle = 'Scaling Exponent';
pTag = 'ScalingExponent';
% Panel and hide button
p = uipanel(gcf, 'Units', 'pixels', 'FontWeight', 'bold', ...
    'BorderType', 'line', 'HighlightColor', [0.5 0.5 0.5], ...
    'Visible', 'off', ...
    'Title', pTitle, ...
    'Tag', pTag, ...
    'Position', [-231 1 230 ph]);
uicontrol(p, 'Style', 'pushbutton', 'String', '-', ...
    'Tag', pTag, ...
    'Callback', @panel.hide, ...
    'Position', [211 ph-25 18 16]);
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
% Fit span
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Fit span:', ...
    'Position', [10 ph-61 100 14]);
ui.fitSpan = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'auto', ...
    'Position', [135 ph-65 51 22]);
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Position', [10 ph-88 120 20]);
% Calculate button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Calculate', ...
    'Callback', @ScalingExponent_Calculate, ...
    'Position', [135 ph-89 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function ScalingExponent_Calculate(hObject, eventdata)
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
fitSpan = sscanf(get(ui.fitSpan, 'String'), '%f', 1);
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

% Check fitSpan value
if isempty(fitSpan) || isnan(fitSpan) || isinf(fitSpan) || fitSpan <= 0
    % set default value
    fitSpan = 0.25;
end
set(ui.fitSpan, 'String', fitSpan);

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

xdata = step*(1:procStepNum);
ydata = zeros(1, procStepNum);
count = zeros(1, procStepNum); % number of statistics for each graph point
for k = 1:length(data)
    xy = data{k}; % coordinates of the current fiber
    n = length(xy); % number of points in the current fiber
    
    shiftNum = min(procStepNum, n-1);
    
    count(1:shiftNum) = count(1:shiftNum) + (n-1:-1:n-shiftNum);
    
    % Cycle for different separations between points along a fiber
    for l = 1:shiftNum
        ydata(l) = ydata(l) + ...
            sum( sqrt( sum( (xy(:,1:end-l) - xy(:,1+l:end)).^2 ) ) );
    end
end

% End-to-end distance
ydata = ydata./count;

% Log values
ydata = log(ydata);
xdata = log(xdata);

se = zeros(size(xdata));
for k = 1:length(xdata)
    ind = (xdata >= xdata(k)-fitSpan) & (xdata <= xdata(k)+fitSpan);
    if nnz(ind) >= 2
        fo = fit(xdata(ind).', ydata(ind).', {'x', '1'});
        se(k) = fo.a;
    else
        se(k) = 1;
    end
end

% Plot graph in a new figure
figure('NumberTitle', 'off', 'Name', ['SE ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
[AX,H1,H2] = plotyy(xdata, ydata, xdata, se, @plot);
set(AX(2), 'XTick', [], 'YColor', 'r');
set(H1, 'Marker', '.', 'LineStyle', 'none');
set(H2, 'Color', 'r');
xlabel('ln(l)');
ylabel(AX(1), 'ln(\langleR\rangle)', 'Color', 'k');
ylabel(AX(2), 'Scaling exponent, \nu', 'Color', 'k');
title(FA.dataName, 'Interpreter', 'none');

% Save results to a text file
if toSave
    [fileName, filePath] = uiputfile('*.txt', ...
        'Save As', ['SE_' FA.dataName(1:end-4) '.txt']);
    if fileName ~= 0
        % Save data
        fileID = fopen(fullfile(filePath, fileName), 'w');
        
        fprintf(fileID, '%s\t%s\t%s\r\n', ...
            'ln(l)', 'ln(<R>)', 'Scaling exponent, \nu');       % Long name
        fprintf(fileID, '%s\t%s\t%s\r\n', '', '', '');          % Units
        fprintf(fileID, '%s\t%s\t%s\r\n', '', '', '');          % Comments
        fprintf(fileID, '%g\t%f\t%g\r\n', [xdata; ydata; se]);  % Data
        
        fclose(fileID);
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Calculate');

