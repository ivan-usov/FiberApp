function NewData(hObject, eventdata)
FA = guidata(hObject);

% Check for modifications
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

FA.imageData = ImageData.empty;
FA.isDataModified = false;
FA.dataName = char.empty;
FA.dataPath = char.empty;
FA.checkAccordance();

