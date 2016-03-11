function p = KinkAngleDistribution
ph = 99; % panel height
pTitle = 'Kink Angle Distribution';
pTag = 'KinkAngleDistribution';
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
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Callback', @HeightDistribution_toSave, ...
    'Position', [10 ph-65 114 20]);
% --- raw data
ui.rawData = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'Enable', 'off', ...
    'String', 'raw data', ...
    'Position', [15 ph-88 100 20]);
% Plot button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Plot', ...
    'Callback', @KinkAngleDistribution_Plot, ...
    'Position', [135 ph-89 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function HeightDistribution_toSave(hObject, eventdata)
ui = get(get(hObject, 'Parent'), 'UserData');
if (get(hObject, 'Value') == get(hObject, 'Max'))
    set(ui.rawData, 'Enable', 'on');
else
    set(ui.rawData, 'Enable', 'off');
end

function KinkAngleDistribution_Plot(hObject, eventdata)
% Handle to the application data
FA = guidata(gcf);

% Check for the data presence
if sum(cellfun(@length, {FA.imageData.xy})) == 0
    msgbox('Empty data');
    return
end

% Get parameters from the panel GUI elements
ui = get(get(hObject, 'Parent'), 'UserData');
angleStep = abs(sscanf(get(ui.angleStep, 'String'), '%f', 1));
toSave = (get(ui.toSave, 'Value') == get(ui.toSave, 'Max'));
rawData = (get(ui.rawData, 'Value') == get(ui.rawData, 'Max'));

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

% Check angleStep value
if isempty(angleStep) || isnan(angleStep) || isinf(angleStep) || angleStep <= 0
    % set default value
    angleStep = 5;
end
numBins = round(180/angleStep);
angleStep = 180/numBins;
set(ui.angleStep, 'String', angleStep);

data = [FA.imageData.xy];
mask = [FA.imageData.mask];
kinkAngle = cellfun(@calculateKinkAngle, data, mask, 'UniformOutput', false);
kinkAngle = [kinkAngle{:}];

% Calculate for 0-180 deg range
edges = linspace(0, 180, numBins+1);
n = histc(kinkAngle, edges);
n(end) = []; % remove pi values (there are impossible anyway)
centers = (edges(1:end-1)+edges(2:end))/2;

% Plot distribution in a new figure
figure('NumberTitle', 'off', 'Name', ['KADist ' datestr(now, 'HH:MM:SS dd/mm/yy')]);
bar(centers, n, 'hist');
title(FA.dataName, 'Interpreter', 'none');
xlim([0 180]);
xlabel('Kink angle, \alpha (deg)');
ylabel('Number of kinks, n_k');

% Save results to a text file
if toSave
    if rawData
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['KADaw_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\r\n', 'Kink angle, \theta');	% Long name
            fprintf(fileID, '%s\r\n', 'deg');                   % Units
            fprintf(fileID, '%s\r\n', '');                      % Comments
            fprintf(fileID, '%g\r\n', kinkAngle);               % Data
            
            fclose(fileID);
        end
        
    else
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['KADist_' FA.dataName(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\t%s\r\n', ...
                'Kink angle, \theta', 'Number of kinks, n_k');	% Long name
            fprintf(fileID, '%s\t%s\r\n', 'deg', '');           % Units
            fprintf(fileID, '%s\t%s\r\n', '', '');              % Comments
            fprintf(fileID, '%g\t%u\r\n', [centers; n]);        % Data
            
            fclose(fileID);
        end
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Plot');

function kinkAngle = calculateKinkAngle(xy, mask)
p = zeros(1, length(xy));
for k = 1:size(mask,2)
    ind = abs(xy(1,:)-mask(1,k)) < mask(3,k)/2 & ...
        abs(xy(2,:)-mask(2,k)) < mask(3,k)/2;
    p(ind) = 1;
end

p = diff(p);
% p = 1 are first points of mask entering vectors
% p = -1 are first points of mask exiting vectors

% If a mask element covers one of the ends, remove a corresponding kink from processing
ind = find(p, 1, 'first');
if p(ind) == -1; p(ind) = 0; end
ind = find(p, 1, 'last');
if p(ind) == 1; p(ind) = 0; end

p1 = find(p == 1);
p2 = find(p == -1);

v1 = xy(:,p1+1)-xy(:,p1); % Entering vectors
v2 = xy(:,p2+1)-xy(:,p2); % Exiting vectors

kinkAngle = 180/pi*acos(sum(v1.*v2)./sqrt(sum(v1.^2).*sum(v2.^2)));

