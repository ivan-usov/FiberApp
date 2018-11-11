%SAVEDATAAS "Save Data As" menu item callback

function isSaved = SaveDataAs(hObject, eventdata)

FA = guidata(hObject);
% Get fileName and filePath
[fileName, filePath] = uiputfile('*.mat', 'Save Data As', ...
    fullfile(FA.dataPath, FA.dataName));
if isequal(fileName, 0); isSaved = false; return
else isSaved = true;
end
% Append .mat if uiputfile returns fileName without this extension
% (this happens if user fileName already contains dot(s) in it)
if ~strcmp(utility.getFileExtension(fileName), 'mat')
    fileName = [fileName '.mat'];
end

FA.dataName = fileName;
FA.dataPath = filePath;

imageData = FA.imageData;
imageData(cellfun(@isempty, {imageData.xy})) = [];
save(fullfile(FA.dataPath, FA.dataName), 'imageData');
% Data saved, and no longer differ from data in the file
FA.isDataModified = false;

% FiberApp tutorial
FA.tutorial('save_as');
