%READFLTIMAGE Read an FLT image (Thermicroscopes SPMLab floating point)

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function [im, sizeX, sizeY, sizeX_nm, sizeY_nm, scaleXY, scaleZ] = ...
    readFltImage(filePath, fileName)
% Initialize variables with empty values
im = [];
sizeX = [];
sizeY = [];
sizeX_nm = [];
sizeY_nm = [];
scaleXY = [];
scaleZ = [];

fid = fopen(fullfile(filePath, fileName));
% Read enought data to fully capture a file header
cHeader = fscanf(fid, '%c', 1100);
sHeader = textscan(cHeader, '%s', 'Delimiter', '');
sHeader = sHeader{1};

% Check if it is an SPMLab file
if isempty(find(strncmp(sHeader, 'Program=SPMLab', 14), 1))
    errordlg('Selected file is not a Thermicroscopes SPMLab file.');
    fclose(fid);
    return
end

% Check if the data in the file is Height data
if isempty(find(strncmp(sHeader, 'DataName=Height', 15), 1))
    errordlg('Selected file does not contain Height information.');
    fclose(fid);
    return
end

% Read dimensionality data and convert all units to 'nm'
sizeX_nm = sscanf(sHeader{strncmp(sHeader, 'ScanRangeX', 10)}, 'ScanRangeX=%f') * 1e3;
sizeY_nm = sscanf(sHeader{strncmp(sHeader, 'ScanRangeY', 10)}, 'ScanRangeY=%f') * 1e3;
sizeX = sscanf(sHeader{strncmp(sHeader, 'ResolutionX', 11)}, 'ResolutionX=%u');
sizeY = sscanf(sHeader{strncmp(sHeader, 'ResolutionY', 11)}, 'ResolutionY=%u');

% XY-scale (nm per one pixel side)
scaleXY = sizeX_nm/(sizeX-1);

% Read the Height data
offset = sscanf(sHeader{strncmp(sHeader, 'DataOffset', 10)}, 'DataOffset=%u');
fseek(fid, offset, 'bof');
im = rot90(fread(fid, [sizeX, sizeY], '*single')) * 255; % artificially broad the intensity range

% Z-scale (nm per one intensity unit)
scaleZ = sscanf(sHeader{strncmp(sHeader, 'ZTransferCoefficient', 20)}, 'ZTransferCoefficient=%f');
scaleZ = scaleZ * 1e3 / 255;

fclose(fid);
