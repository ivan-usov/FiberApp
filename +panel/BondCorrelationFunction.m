function p = BondCorrelationFunction
ph = 122; % panel height
pTitle = 'Bond Correlation Function';
pTag = 'BondCorrelationFunction';
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
% Fitting equation
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'y = exp[ -x / (2Lp) ]', ...
    'Position', [10 ph-38 190 14]);
% Processing length
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Processing length:', ...
    'Position', [10 ph-61 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-61 35 14]);
ui.procLength = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', 'overview', ...
    'Position', [135 ph-65 51 22]);
% Use data weights in curve fitting
ui.isWeighted = uicontrol(p, 'Style', 'checkbox', 'Value', 1, ...
    'String', 'Use data weights in curve fitting', ...
    'Position', [10 ph-88 200 20]);
% Save to a text file
ui.toSave = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Save to a text file', ...
    'Position', [10 ph-111 120 20]);
% Calculate button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Calculate', ...
    'Callback', @BondCorrelationFunction_Calculate, ...
    'Position', [135 ph-112 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);

function BondCorrelationFunction_Calculate(hObject, eventdata)
% Handle to the application data
FA = guidata(gcf);

% Check for the data presence
if sum(cellfun(@length, {FA.imageData.xy})) == 0
    msgbox('Empty data');
    return
end

% Get parameters from the panel GUI elements
ui = get(get(hObject, 'Parent'), 'UserData');
procLength_str = get(ui.procLength, 'String');
isWeighted = (get(ui.isWeighted, 'Value') == get(ui.isWeighted, 'Max'));
toSave = (get(ui.toSave, 'Value') == get(ui.toSave, 'Max'));

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

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

% maxStepNum = max number of vectors - 1 = max number of points - 2
maxStepNum = max(cellfun(@length, data)) - 2;

% Fitting equation and options for the current processing
ft = fittype('exp(-x/(2*lp))');
fo = fitoptions('Method', 'NonlinearLeastSquares', 'Startpoint', 1000, ...
    'Lower', 0, 'Upper', Inf);
dataName_str = FA.dataName;

if strcmpi(procLength_str, 'overview')
    procStepNum = maxStepNum;
    
    % Calculate Bond correlation function vs Internal contour length
    [xdata, ydata, count] = algorithm.BCF(data, step, procStepNum);
    
    set(hObject, 'String', 'Fitting');
    plot_overview(dataName_str, xdata', ydata', ft, fo, isWeighted, count);
else
    procLength = sscanf(procLength_str, '%f', 1);
    if isempty(procLength) || isnan(procLength) || procLength < 3*step
        % set auto value
        procStepNum = round(maxStepNum/2);
    else
        % round procLength to an integer number of steps, but < than maxStepNum
        procStepNum = min([round(procLength/step), maxStepNum]);
    end
    procLength = procStepNum*step;
    set(ui.procLength, 'String', procLength);
    
    % Calculate Bond correlation function vs Internal contour length
    [xdata, ydata, count] = algorithm.BCF(data, step, procStepNum);
    
    set(hObject, 'String', 'Fitting');
    plot_normal(dataName_str, xdata', ydata', ft, fo, isWeighted, count);
    
    % Save results to a text file
    if toSave
        [fileName, filePath] = uiputfile('*.txt', ...
            'Save As', ['BCF_' dataName_str(1:end-4) '.txt']);
        if fileName ~= 0
            % Save data
            fileID = fopen(fullfile(filePath, fileName), 'w');
            
            fprintf(fileID, '%s\t%s\t%s\r\n', ...
                'Internal contour length, l', '<cos(\theta)>', 'Weight'); % Long name
            fprintf(fileID, '%s\t%s\t%s\r\n', 'nm', '', '');              % Units
            fprintf(fileID, '%s\t%s\t%s\r\n', '', '', '');                % Comments
            fprintf(fileID, '%g\t%f\t%g\r\n', [xdata; ydata; count]);     % Data
            
            fclose(fileID);
        end
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Calculate');

function plot_overview(dataName_str, xdata, ydata, ft, fo, isWeighted, count)
lp = zeros(length(xdata)-2, 1);
err = zeros(length(xdata)-2, 1);
r2adj = zeros(length(xdata)-2, 1);

for k = 3:length(xdata)
    if isWeighted
        fo = fitoptions(fo, 'Weights', count(1:k));
    end
    [ff, gof] = fit(xdata(1:k), ydata(1:k), ft, fo);
    cv = coeffvalues(ff);
    ci = confint(ff, 0.99);
    lp(k-2) = cv;
    err(k-2) = cv-ci(1);
    r2adj(k-2) = gof.adjrsquare;
end

figure('NumberTitle', 'off', 'Name', datestr(now, 'HH:MM:SS dd/mm/yy'));

haxis(1) = subplot(3,1,1);
plot(xdata(3:end), lp);
ylabel('\lambda_{BCF}, nm');
title(dataName_str, 'Interpreter', 'none');

haxis(2) = subplot(3,1,2);
plot(xdata(3:end), err);
ylabel('Error, nm');

haxis(3) = subplot(3,1,3);
plot(xdata(3:end), r2adj);
xlabel('Processing length, nm');
ylabel('R^2_{adj}');

set(haxis, 'ActivePositionProperty', 'outerposition');
linkaxes(haxis, 'x');

function plot_normal(dataName_str, xdata, ydata, ft, fo, isWeighted, count)
% Plot a graph in a new figure
if isWeighted
    fo = fitoptions(fo, 'Weights', count);
end
[ff, gof] = fit(xdata, ydata, ft, fo);
cv = coeffvalues(ff);
ci = confint(ff, 0.99);

figure('NumberTitle', 'off', 'Name', datestr(now, 'HH:MM:SS dd/mm/yy'));
plot(ff, xdata, ydata);
xlabel('Internal contour length, l (nm)');
ylabel('\langlecos\theta\rangle');
title(dataName_str, 'Interpreter', 'none');
lp = sprintf('%.2f', cv);
err = sprintf('%.2f', cv-ci(1));
r2adj = sprintf('%f', gof.adjrsquare);
text('Units', 'normalized', 'Position', [0.6 0.95], 'LineStyle', 'none', ...
    'String', ['\lambda = (' lp ' \pm ' err ') nm']);
text('Units', 'normalized', 'Position', [0.6 0.88], 'LineStyle', 'none', ...
    'String', ['R^2_{adj} = ' r2adj]);
legend('off');

