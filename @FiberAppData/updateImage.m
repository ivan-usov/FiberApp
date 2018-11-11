%UPDATEIMAGE Created a new image for viewing (uint8) and display it

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function updateImage(this, varargin)
% Parse input
preserveContrast = false;
preserveView = false;
for k = 1:length(varargin)
    switch varargin{k}
        case 'PreserveContrast'
            preserveContrast = true;
        case 'PreserveView'
            preserveView = true;
        otherwise
            error('FiberApp:updateImage', 'Wrong input argument');
    end
end

% Drop gradient values
this.gradX = [];
this.gradY = [];

if ~preserveContrast
    % Update contrast values
    this.viewMaxZ = double(max(this.im(:)));
    this.viewMinZ = double(min(this.im(:)));
    this.viewMaxZ_nm = this.viewMaxZ*this.scaleZ;
    this.viewMinZ_nm = this.viewMinZ*this.scaleZ;
end

% Create display image (uint8)
scale = 256/(this.viewMaxZ-this.viewMinZ);
displayIm = uint8((2*scale*(this.im-this.viewMinZ)-1)/2);

% Replace old image with a new one
this.spApi.replaceImage(displayIm, this.colorMap, 'PreserveView', preserveView);
