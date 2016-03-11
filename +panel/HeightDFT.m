function p = HeightDFT
ph = 99; % panel height
pTitle = 'Height DFT';
pTag = 'HeightDFT';
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
% Flatten order
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Flatten order:', ...
    'Position', [10 ph-38 100 14]);
ui.flattenOrder = uicontrol(p, 'Style', 'popupmenu', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'none|const|poly1|poly2', ...
    'Value', 3, ...
    'Position', [135 ph-42 51 22]);
% Smooth resulting curve
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Smooth resulting curve:', ...
    'Position', [10 ph-61 120 14]);
ui.smoothingSpan = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 5, ...
    'Position', [135 ph-65 51 22]);
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Position', [10 ph-88 120 20]);
% Calculate button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Calculate', ...
    'Callback', @HeightDFT_Calculate, ...
    'Position', [135 ph-89 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function HeightDFT_Calculate(hObject, eventdata)
% Handle to the application data
FA = guidata(gcf);

% Check for the data presence
if sum(cellfun(@length, {FA.imageData.xy})) == 0
    msgbox('Empty data');
    return
end

% Get parameters from the panel GUI elements
ui = get(get(hObject, 'Parent'), 'UserData');
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

% Maximum number of points withing all fibers
maxNumP = max(cellfun(@length, data))-1;

% Check smoothingSpan value
if isempty(smoothingSpan) || isnan(smoothingSpan) || smoothingSpan == 0
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
    
    % Fast Fourier Transform
    fftz = abs(fft(z, maxNumP));
    ydata = ydata + fftz(1:floor(maxNumP/2)+1);
end

ydata = ydata/max(ydata); % normalize
xdata = (1000/step)*(0:length(ydata)-1)/(length(ydata)-1)/2;

% Smooth resulting curve
if smoothingSpan ~= 0
    ydata = smooth(ydata, smoothingSpan).';
end

% Plot graph in a new figure
figure('NumberTitle', 'off', 'Name', ['H_DFT ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
plot(xdata, ydata);
xlabel('Inverse pitch size, 1000/p (1/nm)');
ylabel('Height DFT');
title(FA.dataName, 'Interpreter', 'none');

% Save results to a text file
if toSave
    [fileName, filePath] = uiputfile('*.txt', ...
        'Save As', ['H_DFT_' FA.dataName(1:end-4) '.txt']);
    if fileName ~= 0
        % Save data
        fileID = fopen(fullfile(filePath, fileName), 'w');
        
        fprintf(fileID, '%s\t%s\r\n', ...
            'Inverse pitch size, 1000/p', 'Amplitude'); % Long name
        fprintf(fileID, '%s\t%s\r\n', '1/nm', '');      % Units
        fprintf(fileID, '%s\t%s\r\n', '', '');          % Comments
        fprintf(fileID, '%f\t%f\r\n', [xdata; ydata]);  % Data
        
        fclose(fileID);
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Calculate');

