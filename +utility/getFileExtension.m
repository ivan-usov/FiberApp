%GETFILEEXTENSION Extract extension of a file

function ext = getFileExtension(fileName)
ind = find(fileName == '.', 1, 'last');
if isempty(ind)
    ext = '';
else
    ext = lower(fileName(ind+1:end));
end
