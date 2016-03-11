function ext = getFileExtension(fileName)
%GETFILEEXTENSION Extract extension of the file
ind = find(fileName == '.', 1, 'last');
if isempty(ind)
    ext = '';
else
    ext = lower(fileName(ind+1:end));
end

