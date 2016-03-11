function p = HeightACF
ph = 145; % panel height
pTitle = 'Height ACF';
pTag = 'HeightACF';
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
% Method
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Method:', ...
    'Position', [10 ph-38 75 14]);
ui.method = uicontrol(p, 'Style', 'radiobutton', 'HorizontalAlignment', 'left', ...
    'Tag', 'rb_height', ...
    'String', 'height', ...
    'Value', 1, ...
    'Callback', @HeightACF_Method, ...
    'Position', [85 ph-42 50 24]);
uicontrol(p, 'Style', 'radiobutton', 'HorizontalAlignment', 'left', ...
    'Tag', 'rb_twistAngle', ...
    'String', 'twist angle', ...
    'Value', 0, ...
    'Callback', @HeightACF_Method, ...
    'Position', [135 ph-42 75 24]);
% Maximum lag
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Maximum lag:', ...
    'Position', [10 ph-61 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-61 35 14]);
ui.maxLag = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 300, ...
    'Position', [135 ph-65 51 22]);
% Flatten order
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Flatten order:', ...
    'Position', [10 ph-84 100 14]);
ui.flattenOrder = uicontrol(p, 'Style', 'popupmenu', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'none|const|poly1|poly2', ...
    'Value', 3, ...
    'Position', [135 ph-88 51 22]);
% Smooth resulting curve
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Smooth resulting curve:', ...
    'Position', [10 ph-107 120 14]);
ui.smoothingSpan = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 5, ...
    'Position', [135 ph-111 51 22]);
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Position', [10 ph-134 120 20]);
% Calculate button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Calculate', ...
    'Callback', @HeightACF_Calculate, ...
    'Position', [135 ph-135 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function HeightACF_Method(hObject, eventdata)
switch get(hObject, 'Tag')
    case 'rb_height'
        set(hObject, 'Value', 1);
        set(findobj('Tag','rb_twistAngle'), 'Value', 0);
        
    case 'rb_twistAngle'
        set(hObject, 'Value', 1);
        set(findobj('Tag','rb_height'), 'Value', 0);
end

function HeightACF_Calculate(hObject, eventdata)
% Handle to the application data
FA = guidata(gcf);

% Check for the data presence
if sum(cellfun(@length, {FA.imageData.xy})) == 0
    msgbox('Empty data');
    return
end

% Get parameters from the panel GUI elements
ui = get(get(hObject, 'Parent'), 'UserData');
method = get(ui.method, 'Value'); % 1 if height, 0 if twist angle
maxLag = abs(sscanf(get(ui.maxLag, 'String'), '%f', 1));
flattenOrder = get(ui.flattenOrder, 'Value');
smoothingSpan = abs(sscanf(get(ui.smoothingSpan, 'String'), '%d', 1));
toSave = (get(ui.toSave, 'Value') == get(ui.toSave, 'Max'));

% Get uniformly distributed data of fibers in nm
step = min([FA.imageData.step_nm]);
data = {FA.imageData.z_nm};
for k = 1:length(FA.imageData)
    data_step = FA.imageData(k).step_nm;
    if data_step ~= step
        len = FA.imageData(k).length_nm;
        num = floor(len/step);
        tail = (len - num*step)/2;
        for l = 1:length(data{k})
            z = data{k}{l};
            data{k}{l} = interp1(data_step*(0:length(z)-1), z, ...
                step*(0:num(l))+tail(l), 'spline');
        end
    end
end
data = [data{:}]; % unite data of all images

% maxStepNum = max lenght in steps = max number of points - 1
maxStepNum = max(cellfun(@length, data)) - 1;

% Maximum lag in steps
if isempty(maxLag) || isnan(maxLag) || maxLag < 5*step
    % set auto value
    maxLagN = round(maxStepNum/4);
else
    % round maxLag to an integer number of steps, but < than maxStepNum
    maxLagN = min([round(maxLag/step), maxStepNum]);
end
maxLag = maxLagN*step;
set(ui.maxLag, 'String', maxLag);

% Check smoothingSpan value
if isempty(smoothingSpan) || isnan(smoothingSpan)
    % set auto value
    smoothingSpan = 5;
end
set(ui.smoothingSpan, 'String', smoothingSpan);

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

ydata = 0;
for k = 1:length(data)
    z = data{k}; % height coordinates of the current fiber
    x = 0:length(z)-1;
    
    switch flattenOrder
        case 1 % none
            % No flattening
        case 2 % const
            z = z - mean(z);
        case 3 % poly1
            fo = fit(x', z', 'poly1');
            z = z - (fo.p1*x + fo.p2);
        case 4 % poly2
            fo = fit(x', z', 'poly2');
            z = z - (fo.p1*x.^2 + fo.p2*x + fo.p3);
    end
    
    if method == 0 % Twist angle
        s = sign(diff(z));
        if ~all(s); msgbox('ACF', 'Zero'); end
        ss = [0, diff(s)/2];
        ind = find(ss);
        ss = ss(ss~=0);
        len = diff(ind);
        
        z = [];
        for l = 1:length(len)
            xx = linspace(0, pi, len(l)+1);
            if ss(l) == -1
                z = [z(1:end-1), cos(xx)];
            else
                z = [z(1:end-1), -cos(xx)];
            end
        end
    end
    
    % Autocorrelation Function
    acf = xcorr(z, maxLagN, 'unbiased');
    ydata = ydata + acf(maxLagN+1:end);
end

% Smooth resulting curve
if smoothingSpan ~= 0
    ydata = smooth(ydata, smoothingSpan).';
end

ydata = ydata/max(ydata); % normalize
xdata = (0:length(ydata)-1)*step;

% Plot graph in a new figure
figure('NumberTitle', 'off');
plot(xdata, ydata);
xlim([0, maxLag]); % set the correct limits
xlabel('Lag, nm');
if method == 1
    set(gcf, 'Name', ['H_ACF ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
    ylabel('Height ACF');
else
    set(gcf, 'Name', ['TA_ACF ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
    ylabel('Twist angle ACF');
end
title(FA.dataName, 'Interpreter', 'none');

% Save results to a text file
if toSave
    if method == 1
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['H_ACF_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\t%s\r\n', ...
                'Lag', 'Height ACF');                       % Long name
            fprintf(fileID, '%s\t%s\r\n', 'nm', '');        % Units
            fprintf(fileID, '%s\t%s\r\n', '', '');          % Comments
            fprintf(fileID, '%f\t%f\r\n', [xdata; ydata]);  % Data
            
            fclose(fileID);
        end
    else
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['TA_ACF_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\t%s\r\n', ...
                'Lag', 'Twist angle ACF');                  % Long name
            fprintf(fileID, '%s\t%s\r\n', 'nm', '');        % Units
            fprintf(fileID, '%s\t%s\r\n', '', '');          % Comments
            fprintf(fileID, '%f\t%f\r\n', [xdata; ydata]);  % Data
            
            fclose(fileID);
        end
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Calculate');

