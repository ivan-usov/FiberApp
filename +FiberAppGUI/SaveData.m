%SAVEDATA "Save Data" menu item callback

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function isSaved = SaveData(hObject, eventdata)

FA = guidata(hObject);
if isempty(FA.dataPath)
    isSaved = FiberAppGUI.SaveDataAs(hObject, eventdata);
else
    isSaved = true;
    imageData = FA.imageData;
    imageData(cellfun(@isempty, {imageData.xy})) = [];
    save(fullfile(FA.dataPath, FA.dataName), 'imageData');
    % Data saved, and no longer differ from data in the file
    FA.isDataModified = false;
end
