function [im, sizeX, sizeY, sizeX_nm, sizeY_nm, scaleXY, scaleZ] = ...
    readNanoScopeImage(filePath, fileName)

% Initialize variables with empty values
im = [];
sizeX = [];
sizeY = [];
sizeX_nm = [];
sizeY_nm = [];
scaleXY = [];
scaleZ = [];

fid = fopen(fullfile(filePath, fileName));
% Max header length 40960 (80960 in a new version)
cHeader = fscanf(fid, '%c', 80960);
sHeader = textscan(cHeader, '%s', 'Delimiter', '', 'BufSize', 80960);
sHeader = sHeader{1};

% Check for an Image Data (Height, Phase, Amplitude etc.) in the file
ind = find(strncmp(sHeader, '\@2:Image Data: S', 17));
if isempty(ind)
    errordlg('Selected file is not a NanoScope AFM file.');
    fclose(fid);
    return
end
n = length(ind);
image_data = cell(1, n);
for k = 1:n
    % Read the text between quotes
    idx = find(sHeader{ind(k)} == '"');
    image_data{k} = sHeader{ind(k)}(idx(1)+1:idx(2)-1);
end

% Check for a Height channels in the file
ind_h = find(strcmp(image_data, 'Height'));
if isempty(ind_h)
    errordlg('Selected file does not contain any Height Channels.');
    fclose(fid);
    return
end
n_h = length(ind_h);

% Line directions for all image channels (to show in dialog window)
line_dir = cell(1, n);
ind = find(strncmp(sHeader, '\Line Direction:', 16));
for k = 1:n
    line_dir{k} = sscanf(sHeader{ind(k)}, '\\Line Direction: %s');
end

% If there are more than one height channel open dialog box to select one
if n_h > 1
    list_str = strcat(image_data(ind_h), {':'}, line_dir(ind_h));
    [sel, ok] = listdlg(...
        'Name', 'Select channel', ...
        'PromptString', 'Height channels in the file:', ...
        'ListString', list_str, ...
        'SelectionMode', 'Single', ...
        'ListSize', [170 100]);
    if ~ok
        fclose(fid);
        return
    end
else sel = 1;
end

% Image size along x axis in nm
ind = find(strncmp(sHeader, '\Scan Size:', 11), 1, 'first');
sizeX_nm = sscanf(sHeader{ind}, '\\Scan Size: %u nm');

% Image size along x axis in pix
ind = find(strncmp(sHeader, '\Samps/line:', 12), 1, 'first');
sizeX = sscanf(sHeader{ind}, '\\Samps/line: %u');

% XY-scale (nm per one pixel side)
scaleXY = sizeX_nm/(sizeX-1);

% Image size along y axis in pix
ind = find(strncmp(sHeader, '\Lines:', 7), 1, 'first');
sizeY = sscanf(sHeader{ind}, '\\Lines: %u');

% Calculate image size along y axis in nm
% (distance in nm = distance between centers of two border pixels)
sizeY_nm = round(scaleXY*(sizeY-1));

% Z scale for height image channels
zScaleV = zeros(1, n_h);
ind = find(strncmp(sHeader, '\@2:Z scale: V [Sens. Zsens]', 28));
for k = 1:n_h
    zScaleV(k) = sscanf(sHeader{ind(k)}, ...
        '\\@2:Z scale: V [Sens. Zsens] (%*f V/LSB) %f V');
end

% Z sens. - parameter for Z-scale calculation
ind = find(strncmp(sHeader, '\@Sens. Zsens:', 14), 1, 'first');
zSens = sscanf(sHeader{ind}, '\\@Sens. Zsens: V %f nm/V');

% Z-scale (nm per one intensity unit)
scaleZ = zSens*zScaleV(sel)/65536;

% Data offsets for all image channels
data_offset = zeros(1, n);
ind = find(strncmp(sHeader, '\Data offset:', 13));
for k = 1:n
    data_offset(k) = sscanf(sHeader{ind(k)}, '\\Data offset: %u');
end

% Read image data
fseek(fid, data_offset(ind_h(sel)), 'bof');
im = rot90(fread(fid, [sizeX, sizeY], '*int16'));

fclose(fid);

