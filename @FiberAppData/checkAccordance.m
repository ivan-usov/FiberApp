%CHECKACCORDANCE Check accordance between a fiber data and an image 

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function checkAccordance(this)
% Clean axes from fibers
delete(this.fibLine);
this.fibLine = [];
% Delete fiber rectangles from memory
this.fibRect = [];

% Clean axes from masks
delete(this.maskLine);
this.maskLine = [];

% Drop the selection number
this.sel = 0;

% Clear fiber data of "empty" images
this.imageData(cellfun(@isempty, {this.imageData.xy})) = [];

% Look for a name of the current image in the data
if isempty(this.imageData)
    names = '';
else
    names = {this.imageData.name};
end

ind = find(strcmp(names, this.name), 1);
if isempty(ind) % Image is new
    this.imageData(end+1) = ImageData;
    this.curIm = this.imageData(end);
    
    % Save image parameters
    this.curIm.name = this.name;
    this.curIm.sizeX = this.sizeX;
    this.curIm.sizeY = this.sizeY;
    this.curIm.sizeX_nm = this.sizeX_nm;
    this.curIm.sizeY_nm = this.sizeY_nm;
    this.curIm.scaleXY = this.scaleXY;
    this.curIm.scaleZ = this.scaleZ;
    
    % Save tracking parameters
    this.curIm.alpha = this.alpha;
    this.curIm.beta = this.beta;
    this.curIm.gamma = this.gamma;
    this.curIm.kappa1 = this.kappa1;
    this.curIm.kappa2 = this.kappa2;
    this.curIm.fiberIntensity = this.fiberIntensity;
    this.curIm.step = this.step;
    this.curIm.step_nm = this.step_nm;
    
    if isempty(this.dataName)
        this.dataName = 'new_data.mat';
    end
    
else % Image already has fiber data
    this.curIm = this.imageData(ind);
    
    % Retrieve tracking parameters
    this.alpha = this.curIm.alpha;
    this.beta = this.curIm.beta;
    this.gamma = this.curIm.gamma;
    this.kappa1 = this.curIm.kappa1;
    this.kappa2 = this.curIm.kappa2;
    this.fiberIntensity = this.curIm.fiberIntensity;
    this.step = this.curIm.step;
    this.step_nm = this.curIm.step_nm;
    
    % Retrieve tracked fibers
    for k = 1:length(this.imageData.xy)
        xy = this.curIm.xy{k};
        this.fibLine(end+1) = line(xy(1,:), xy(2,:));
    end
    
    switch this.fiberStyle
        case 1 % 'line'
            set(this.fibLine, 'Marker', 'none', 'LineStyle', '-');
        case 2 % 'point'
            set(this.fibLine, 'Marker', '.', 'LineStyle', 'none');
    end
    set(this.fibLine, 'Color', this.fiberColor, 'LineWidth', this.fiberWidth);
    
    this.fibRect = cell2mat(cellfun(@(xy) [min(xy,[],2); max(xy,[],2)], ...
        this.curIm.xy, 'UniformOutput', false));
    this.renderFibers();
end
