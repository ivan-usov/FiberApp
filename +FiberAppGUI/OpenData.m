%OPENDATA "Open Data" menu item callback

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function isOpened = OpenData(hObject, eventdata)

FA = guidata(hObject);
% Check for new modifications
if FA.isDataModified
    switch questdlg('Do you want to save changes?', 'FiberApp')
        case 'Yes'
            isSaved = FiberAppGUI.SaveData(hObject, eventdata);
            if ~isSaved; return; end
        case 'No'
        case {'Cancel', ''}
            return
    end
end

[fileName, filePath] = uigetfile('*.mat', 'Open Data');
if isequal(fileName, 0)
    isOpened = false;
    return
else
    isOpened = true;
end

FA.dataName = fileName;
FA.dataPath = filePath;

loaded = load(fullfile(filePath, fileName));
FA.imageData = loaded.imageData;

% Support old format data files
for k = 1:length(FA.imageData)
    if isempty(FA.imageData(k).mask)
        FA.imageData(k).mask = cell(size(FA.imageData(k).xy));
    end
    if isempty(FA.imageData(k).alpha)
        FA.imageData(k).alpha = 0;
        FA.imageData(k).beta = 500;
        FA.imageData(k).gamma = 20;
        FA.imageData(k).kappa1 = 20;
        FA.imageData(k).kappa2 = 20;
        FA.imageData(k).fiberIntensity = 100;
    end
end

% Data loaded, and no longer differ from data in the file
FA.isDataModified = false;

% If no image opened, no association, just update statistics
if isempty(FA.curIm)
    FA.sel = 0;
else
    FA.checkAccordance();
end

% Change a current folder
cd(filePath);
