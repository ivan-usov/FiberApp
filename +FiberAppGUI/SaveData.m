% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
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

