% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
classdef ImageData < handle    
    properties % Stored image information
        name = char.empty;
        sizeX
        sizeY
        sizeX_nm
        sizeY_nm
        scaleXY % sizeX_nm/sizeX = sizeY_nm/sizeY;
        scaleZ
    end
    
    properties % Stored tracking parameters
        alpha
        beta
        gamma
        kappa1
        kappa2
        fiberIntensity
    end
    
    properties % Stored fibers data
        step
        step_nm
        xy = cell.empty;
        z = cell.empty;
        mask = cell.empty;
    end
    
    properties (Dependent, SetAccess = private)
        xy_nm
        z_nm
        length_nm
        height_nm
    end
    
    methods
        function step_nm = get.step_nm(this)
            step_nm = this.step*this.scaleXY;
        end
        
        function xy_nm = get.xy_nm(this)
            xy_nm = cellfun(@(xy) xy.*this.scaleXY, this.xy, ...
                'UniformOutput', false);
        end
        
        function z_nm = get.z_nm(this)
            z_nm = cellfun(@(z) z.*this.scaleZ, this.z, ...
                'UniformOutput', false);
        end
        
        function length_nm = get.length_nm(this)
            length_nm = cellfun(@(xy) (length(xy)-1)*this.step_nm, this.xy);
        end
        
        function height_nm = get.height_nm(this)
            height_nm = cellfun(@(z) mean(z), this.z_nm);
        end
    end
end

