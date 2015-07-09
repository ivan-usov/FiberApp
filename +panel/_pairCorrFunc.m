function varargout = pairCorrFunc(varargin)
% PAIRCORRFUNC MATLAB code for pairCorrFunc.fig

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @pairCorrFunc_OpeningFcn, ...
                   'gui_OutputFcn',  @pairCorrFunc_OutputFcn, ...
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

function pairCorrFunc_OpeningFcn(hObject, eventdata, handles, varargin)
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

p = get_points(handles.xyFib);
handles.xMin = min(p(1,:));
handles.xMax = max(p(1,:));
handles.yMin = min(p(2,:));
handles.yMax = max(p(2,:));
set(handles.e_xMin, 'String', handles.xMin);
set(handles.e_xMax, 'String', handles.xMax);
set(handles.e_yMin, 'String', handles.yMin);
set(handles.e_yMax, 'String', handles.yMax);

handles.graphStep = 10*handles.sFib;
handles.procLength = 1000;
set(handles.e_graphStep, 'String', handles.graphStep);
set(handles.e_procLength, 'String', handles.procLength);

handles.periodicBox = true;
handles.saveToFile = false;

% Choose default command line output for pairCorrFunc
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);

function varargout = pairCorrFunc_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

function pb_selectArea_Callback(hObject, eventdata, handles)
hfigMain = guidata(handles.figMain);
rect = getrect(handles.figMain);
handles.xMin = rect(1)*hfigMain.xyScale;
handles.xMax = (rect(1)+rect(3))*hfigMain.xyScale;
handles.yMin = rect(2)*hfigMain.xyScale;
handles.yMax = (rect(2)+rect(4))*hfigMain.xyScale;
set(handles.e_xMin, 'String', handles.xMin);
set(handles.e_xMax, 'String', handles.xMax);
set(handles.e_yMin, 'String', handles.yMin);
set(handles.e_yMax, 'String', handles.yMax);
guidata(hObject, handles);

function setArea_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
switch get(hObject, 'Tag')
    case 'e_xMin'
        if isnan(val)
            set(hObject, 'String', handles.xMin);
            errordlg('Xmin must be a number', 'Error');
            return
        elseif val >= handles.xMax
            set(hObject, 'String', handles.xMin);
            errordlg('Xmin must be smaller than Xmax', 'Error');
            return
        end
        handles.xMin = val;
        
    case 'e_xMax'
        if isnan(val)
            set(hObject, 'String', handles.xMax);
            errordlg('Xmax must be a number', 'Error');
            return
        elseif val <= handles.xMin
            set(hObject, 'String', handles.xMax);
            errordlg('Xmax must be larger than Xmin', 'Error');
            return
        end
        handles.xMax = val;
        
    case 'e_yMin'
        if isnan(val)
            set(hObject, 'String', handles.yMin);
            errordlg('Ymin must be a number', 'Error');
            return
        elseif val >= handles.yMax
            set(hObject, 'String', handles.yMin);
            errordlg('Ymin must be smaller than Ymax', 'Error');
            return
        end
        handles.yMin = val;
                
    case 'e_yMax'
        if isnan(val)
            set(hObject, 'String', handles.yMax);
            errordlg('Ymax must be a number', 'Error');
            return
        elseif val <= handles.yMin
            set(hObject, 'String', handles.yMax);
            errordlg('Xmax must be larger than Xmin', 'Error');
            return
        end
        handles.yMax = val;
end
guidata(hObject, handles);

function e_graphStep_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val)
    set(hObject, 'String', handles.graphStep);
    errordlg('Graph Step must be a number', 'Error');
    return
end
handles.graphStep = val;
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

function cb_periodicBox_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == get(hObject, 'Max')
	handles.periodicBox = true;
else
	handles.periodicBox = false;
end
guidata(hObject, handles);

function cb_saveToFile_Callback(hObject, eventdata, handles)
if get(hObject, 'Value') == get(hObject, 'Max')
	handles.saveToFile = true;
else
	handles.saveToFile = false;
end
guidata(hObject, handles);

function pb_calculate_Callback(hObject, eventdata, handles)
xMin = handles.xMin;
xMax = handles.xMax;
yMin = handles.yMin;
yMax = handles.yMax;

p = get_points(handles.xyFib, xMin, xMax, yMin, yMax);
if isempty(p);
    warndlg('There are no fibers in the selected area');
    return
end

graphStep = handles.graphStep;
graphStepNum = floor(handles.procLength/graphStep);
edges = graphStep*(0:graphStepNum);

% +1 due to histc output (last number counts any values of x that match edges(end))
ydata = zeros(1, graphStepNum+1);

x = p(1,:);
y = p(2,:);
if handles.periodicBox
    %%% Periodic box
    xSide = xMax-xMin;
    ySide = yMax-yMin;
    xHalf = xSide/2;
    yHalf = ySide/2;
    for k = 1:length(p)-1
        % Differences in coordinates
        xDiff = x(k+1:end)-x(k);
        yDiff = y(k+1:end)-y(k);
        
        % Periodic conditions
        xDiff(xDiff>xHalf) = xSide - xDiff(xDiff>xHalf);
        yDiff(yDiff>yHalf) = ySide - yDiff(yDiff>yHalf);
        
        ydata = ydata + histc(sqrt(xDiff.^2+yDiff.^2), edges);
    end
else
    %%% Non-periodic box
    
end

% TODO
ydata = ydata(1:end-1);
xdata = graphStep*((1:length(ydata)));
ydata = 2*ydata/(length(p)-1);
ydata = cumsum(ydata);
ringSquares = pi*(xdata.^2);
ydata = ydata./ringSquares;

density = length(p)/((xMax-xMin)*(yMax-yMin));
ydata = ydata/density;

figure;
plot(xdata, ydata);
title('Pair correlation function');
xlabel('Distance, r (nm)');
ylabel('g(r)');
legend('off');

if handles.saveToFile
    [filename filepath] = uiputfile('*.txt', 'Save As', 'PairCorFunc');
    if filename == 0
        return
    end

    tosave = [xdata ydata];
    save(fullfile(filepath, filename), 'tosave', '-ascii');
end

function p = get_points(data_cell, varargin)
p = [data_cell{:}];

if ~isempty(varargin)
    xMin = varargin{1};
    xMax = varargin{2};
    yMin = varargin{3};
    yMax = varargin{4};
    % Cut along X and Y axes
    ind = (xMin<=p(1,:) & p(1,:)<xMax & yMin<=p(2,:) & p(2,:)<yMax);
    p = p(:,ind);
end

function pb_close_Callback(hObject, eventdata, handles)
delete(gcf);
