function updateImage(this, varargin)
%UPDATEIMAGE Update image for viewing (uint8) and display it
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

