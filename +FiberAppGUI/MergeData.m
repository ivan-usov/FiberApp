% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function MergeData(hObject, eventdata)
% Get addresses of the files to merge
[fileName, filePath] = uigetfile('*.mat', 'Select data files to merge', ...
    'MultiSelect', 'on');

if isequal(fileName, 0) % Cancel or close
    return
    
elseif ischar(fileName) % Only one file was selected
    errordlg('Select at least two data files to merge', 'Merge Data Error');
    return
end % Then several files were selected

% Load information from the data files
imageData = ImageData.empty;
for k = 1:length(fileName)
    loadData = load([filePath fileName{k}]);
    imageData_ = loadData.imageData;
    for l = 1:length(imageData_)
        % Determine repeating images
        ind =  find(strcmp({imageData.name}, imageData_(l).name), 1);
        if isempty(ind)
            % Add as a new image data
            imageData = [imageData imageData_(l)];
        else
            % Check the step size
            if imageData(ind).step == imageData_(l).step
                % Unite data
                imageData(ind).xy = [imageData(ind).xy imageData_(l).xy];
                imageData(ind).z = [imageData(ind).z imageData_(l).z];
                imageData(ind).mask = [imageData(ind).mask imageData_(l).mask];
            else
                errordlg(['It is not possible to combine data from the same image', ...
                    ' but with different step sizes. The merge process will be stopped.'], ...
                    'Merge Data Error');
                return
            end
        end
    end
end

% Get address of the output file
[fileNameOut, filePathOut] = uiputfile('*.mat', 'Save merged data as', 'merged_data');
if isequal(fileNameOut, 0); return; end
% Append .mat if uiputfile returns fileName without this extension
% (this happens if user fileName already contains dot(s) in it)
if ~strcmp(utility.getFileExtension(fileNameOut), 'mat')
    fileNameOut = [fileNameOut '.mat'];
end

save(fullfile(filePathOut, fileNameOut), 'imageData');

