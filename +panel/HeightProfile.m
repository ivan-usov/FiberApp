%HEIGHTPROFILE Create a height profile panel

function p = HeightProfile
ph = 53; % panel height
pTitle = 'Height Profile';
pTag = 'HeightProfile';
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
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Position', [10 ph-42 114 20]);
% Plot button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Plot', ...
    'Callback', @HeightProfile_Plot, ...
    'Position', [135 ph-43 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function HeightProfile_Plot(hObject, eventdata)
% Handle to the application data
FA = guidata(hObject);

% Check if there is a selected fiber
if FA.sel == 0; return; end

% Get parameters from the panel GUI elements
ui = get(get(hObject, 'Parent'), 'UserData');
toSave = get(ui.toSave, 'Value') == get(ui.toSave, 'Max');

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

% Height profile data
ydata = FA.curIm.z_nm{FA.sel};
xdata = (0:length(ydata)-1)*FA.step_nm;

% Plot graph in a new figure
figure('NumberTitle', 'off', 'Name', ['HProf ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
plot(xdata, ydata);
title(['Height profile, #', int2str(FA.sel)], 'Interpreter', 'none');
xlabel('Internal contour length, l (nm)');
ylabel('Height, h (nm)');

% Save results to a text file
if toSave
    [fileName, filePath] = uiputfile('*.txt', ...
        'Save As', ['HProf_' int2str(FA.sel) '.txt']);
    if fileName ~= 0
        % Save data
        fileID = fopen(fullfile(filePath, fileName), 'w');
        
        fprintf(fileID, '%s\t%s\r\n', ...
            'Internal contour length, l', 'Height, h'); % Long name
        fprintf(fileID, '%s\t%s\r\n', 'nm', 'nm');      % Units
        fprintf(fileID, '%s\t%s\r\n', '', '');          % Comments
        fprintf(fileID, '%g\t%f\r\n', [xdata; ydata]);  % Data
        
        fclose(fileID);
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Plot');
