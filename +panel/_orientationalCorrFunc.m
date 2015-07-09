function varargout = orientationalCorrFunc(varargin)
% ORIENTATIONALCORRFUNC MATLAB code for orientationalCorrFunc.fig

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @orientationalCorrFunc_OpeningFcn, ...
                   'gui_OutputFcn',  @orientationalCorrFunc_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

function orientationalCorrFunc_OpeningFcn(hObject, eventdata, handles, varargin)
handles.figMain = varargin{1};
hfigMain = guidata(handles.figMain);

FibS = cell(1, length(hfigMain.ScaleXY));
FibXY = cell(1, length(hfigMain.ScaleXY));
for k = 1:length(hfigMain.ScaleXY)
    FibS{k} = hfigMain.FibS{k}*hfigMain.ScaleXY(k);
    FibXY{k} = cellfun(@(x) x*hfigMain.ScaleXY(k), hfigMain.FibXY{k}, ...
        'UniformOutput', false);
end
[handles.sFib handles.xyFib] = checkFiberStep([FibS{:}], [FibXY{:}]);

handles.graphStep = 3*handles.sFib;
handles.procLength = 1000;
handles.saveToFile = false;

set(handles.e_graphStep, 'String', handles.graphStep);
set(handles.e_procLength, 'String', handles.procLength);
set(handles.cb_saveToFile, 'Value', get(handles.cb_saveToFile, 'Min'));

% Choose default command line output for orientationalCorrFunc
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

function varargout = orientationalCorrFunc_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

function e_graphStep_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val)
    set(hObject, 'String', handles.graphStep);
    errordlg('Graph Step must be a number', 'Error');
    return
end
handles.graphStep = round(val/handles.sFib)*handles.sFib;
set(hObject, 'String', handles.graphStep);
guidata(hObject, handles);

function e_procLength_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val)
    set(hObject, 'String', handles.procLength);
    errordlg('Processing Length must be a number', 'Error');
    return
end
handles.procLength = val;
guidata(hObject, handles);

function cb_saveToFile_Callback(hObject, eventdata, handles)
if get(hObject,'Value') == get(hObject,'Max')
	handles.saveToFile = true;
else
	handles.saveToFile = false;
end
guidata(hObject, handles);

function pb_calculate_Callback(hObject, eventdata, handles)
% Prevent double clicks
set(handles.pb_calculate, 'Enable', 'off');

fibNum = length(handles.xyFib);

graphStep = handles.graphStep;

% Max number of points in the output
procStepNum = floor(handles.procLength/graphStep);
procLength = procStepNum*graphStep;

ydata = zeros(procStepNum, 1);
counter = zeros(procStepNum, 1);

[p v] = get_data(handles.xyFib);

fibNumStr = int2str(fibNum);
for k = 1:fibNum-1
    % Update status string every 33 fibrils
    set(handles.t_status, 'String', [int2str(k) '/' fibNumStr]);
    drawnow update;
    
    p1 = p{k};
    p2 = [p{k+1:end}];
    
    v1 = v{k};
    v2 = [v{k+1:end}];
    
    for l = 1:length(p1)
        dist = (p2(1,:)-p1(1,l)).^2 + (p2(2,:)-p1(2,l)).^2;
        ind = (dist <= procLength.^2);
        if isempty(ind); continue; end
        numStep = ceil(sqrt(dist(ind))./graphStep);
        res = (v1(1,l).*v2(1,ind) + v1(2,l).*v2(2,ind)).^2;
        for m = 1:procStepNum
            val = res(numStep == m);
            if isempty(val); continue; end
            ydata(m) = ydata(m) + sum(val);
            counter(m) = counter(m) + length(val);
        end
    end
end

xdata = graphStep*(1:procStepNum)';
ydata = ydata./counter;
ydata = 2*ydata-1;

% Status string: 'Ready'
set(handles.t_status, 'String', 'Ready');

% Recover Calculation button
set(handles.pb_calculate, 'Enable', 'on');

% Plot a graph in a new figure
figure;
ft = fittype('a+(1-a)*exp(-x/(2*l_1))', 'Coefficients', {'a', 'l_1'});
fo = fitoptions('Method', 'NonlinearLeastSquares', ...
    'Startpoint', [0.5 1000], 'Lower', [0 0], 'Upper', [1 Inf]);
ff = fit(xdata, ydata, ft, fo);
cv = coeffvalues(ff);
plot(ff, xdata, ydata);
title({num2str(cv(1)); num2str(cv(2))});
xlabel('Contour length, s (nm)');
ylabel('Mean-square end-to-end distance, <R^2> (nm^2)');
legend('off');

if handles.saveToFile
    [filename filepath] = uiputfile('*.txt', 'Save As', 'End2endDist');
    if filename == 0; return; end
    tosave = [xdata ydata];
    save(fullfile(filepath, filename), 'tosave', '-ascii');
end

function [p v] = get_data(data_cell)
% p - coordinates of vectors beginnings
p = cellfun(@(x) x(:,1:end-1), data_cell, 'UniformOutput', false);

% v - normalized vectors
v = cellfun(@get_vect, data_cell, 'UniformOutput', false);

function v = get_vect(xy)
vect_ = diff(xy, 1, 2);
leng_ = sqrt(sum(vect_.^2));
v = vect_./[leng_; leng_];

function pb_close_Callback(hObject, eventdata, handles)
delete(gcf);
