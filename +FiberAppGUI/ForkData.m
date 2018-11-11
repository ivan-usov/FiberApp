%FORKDATA "Fork Data" menu item callback

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function ForkData(hObject, eventdata)

% Get address of the file to split data from
[fileName, filePath] = uigetfile('*.mat', 'Select file to fork from');
if isequal(fileName, 0); return; end

% Load information from the data file
loadData = load(fullfile(filePath, fileName));

dataNames = {loadData.imageData.name};
[sel, ok] = listdlg(...
    'Name', 'Split Data', ...
    'PromptString', {'Select image data to fork from this data file.', ...
    'Hold Ctrl to select multiple items.', ''}, ...
    'ListString' , dataNames, ...
    'SelectionMode', 'multiple', ...
    'ListSize', [170 100]);
if ~ok || isempty(sel); return; end

% Get address of the file to save splitted data
[fileNameOut, filePathOut] = uiputfile('*.mat', 'Save forked data as', 'forked_data');
if isequal(fileNameOut, 0); return; end

imageData = loadData.imageData(sel);
save(fullfile(filePathOut, fileNameOut), 'imageData');
