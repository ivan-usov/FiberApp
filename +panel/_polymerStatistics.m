function varargout = polymerStatistics(varargin)
%STATISTICS M-file for molarMassAvg.fig

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @molarMassAvg_OpeningFcn, ...
                   'gui_OutputFcn',  @molarMassAvg_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
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

function molarMassAvg_OpeningFcn(hObject, eventdata, handles, varargin)
hfigMain = guidata(varargin{1});

FibS = cell(1, length(hfigMain.ScaleXY));
for k = 1:length(hfigMain.ScaleXY)
    FibS{k} = hfigMain.FibS{k}*hfigMain.ScaleXY(k);
end

handles.len_nm = cellfun(@(x) length(x)-1, [hfigMain.FibXY{:}]).*[FibS{:}];

set(handles.e_totNum, 'String', sum(hfigMain.FibN));
set(handles.e_averageLength_nm, 'String', mean(handles.len_nm));

handles.monomerLength = 0;
handles.monomerWeight = 0;
set(handles.e_monomerLength, 'String', handles.monomerLength);
set(handles.e_monomerWeight, 'String', handles.monomerWeight);

handles.rangeMin = 0;
handles.rangeMax = max(handles.len_nm)+10;
handles.binsNumber = 100;
set(handles.e_rangeMin, 'String', handles.rangeMin);
set(handles.e_rangeMax, 'String', handles.rangeMax);
set(handles.e_binsNumber, 'String', handles.binsNumber);

% Choose default command line output for molarMassAvg
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
calculateStat(handles);

function varargout = molarMassAvg_OutputFcn(hObject, eventdata, handles)
% Get default command line output from handles structure
varargout{1} = handles.output;

function e_monomerLength_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val)
    set(hObject, 'String', handles.graphStep);
    errordlg('Monomer Length must be a number', 'Error');
    return
end
handles.monomerLength = val;
guidata(hObject, handles);
calculateStat(handles);

function e_monomerWeight_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val)
    set(hObject, 'String', handles.procLength);
    errordlg('Monomer Weight must be a number', 'Error');
    return
end
handles.monomerWeight = val;
guidata(hObject, handles);
calculateStat(handles);

function calculateStat(handles)
len_monomer = round(handles.len_nm/handles.monomerLength);
masses = len_monomer.*handles.monomerWeight;
% mn - Number average molecular weight
mn = sum(masses)./length(len_monomer);
% mw - Weight average molecular weight
mw = sum(masses.^2)./sum(masses);
% pdi - Polydispersity index
pdi = mw./mn;
set(handles.e_Mn, 'String', mn);
set(handles.e_Mw, 'String', mw);
set(handles.e_PDI, 'String', pdi);

function e_range_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
switch get(hObject, 'Tag')
    case 'e_rangeMin'
        if isnan(val)
            set(hObject, 'String', handles.rangeMin);
            errordlg('RangeMin must be a number', 'Error');
            return
        elseif val >= handles.rangeMax
            set(hObject, 'String', handles.rangeMin);
            errordlg('RangeMin must be smaller than RangeMax', 'Error');
            return
        end
        handles.rangeMin = val;
        
    case 'e_rangeMax'
        if isnan(val)
            set(hObject, 'String', handles.rangeMax);
            errordlg('RangeMax must be a number', 'Error');
            return
        elseif val <= handles.rangeMin
            set(hObject, 'String', handles.rangeMax);
            errordlg('RangeMax must be larger than RangeMin', 'Error');
            return
        end
        handles.rangeMax = val;
end
guidata(hObject, handles);

function e_binsNumber_Callback(hObject, eventdata, handles)
val = str2double(get(hObject, 'String'));
if isnan(val)
    set(hObject, 'String', handles.binsNumber);
    errordlg('Bins Number must be a number', 'Error');
    return
end
handles.binsNumber = val;
guidata(hObject, handles);

function pb_plotDistribution_Callback(hObject, eventdata, handles)
edges = linspace(handles.rangeMin, handles.rangeMax, handles.binsNumber+1);
n = histc(handles.len_nm, edges);
figure;
bar(edges(1:end-1), n(1:end-1), 'histc');
title('Length distribution');
xlabel('Length, l (nm)');
ylabel('Counts');

[filename filepath] = uiputfile('*.txt', 'Save As', 'test');
if filename == 0; return; end
tosave = [(edges(1:end-1)+(edges(2:end)-edges(1:end-1))/2).' n(1:end-1)];
save(fullfile(filepath, filename), 'tosave', '-ascii');

function pb_close_Callback(hObject, eventdata, handles)
delete(gcf);
