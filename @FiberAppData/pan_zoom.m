function pan_zoom(this, varargin)
switch varargin{1}
    case 'z_in'     % Zoom in
        scale = 1.2;
        cp = get(gca, 'CurrentPoint');
        x = cp(1,1);
        y = cp(1,2);
        r = this.spApi.getVisibleImageRect();
        mag = this.spApi.getMagnification();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y)
            this.spApi.setMagnification(mag*scale);
        else
            this.spApi.setMagnificationAndCenter(mag*scale, ...
                (r(1)+r(3)/2-x)/scale+x, (r(2)+r(4)/2-y)/scale+y);
        end
        
    case 'z_out'    % Zoom out
        scale = 1.2;
        cp = get(gca, 'CurrentPoint');
        x = cp(1,1);
        y = cp(1,2);
        r = this.spApi.getVisibleImageRect();
        mag = this.spApi.getMagnification();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y)
            this.spApi.setMagnification(mag/scale);
        else
            this.spApi.setMagnificationAndCenter(mag/scale, ...
                (r(1)+r(3)/2-x)*scale+x, (r(2)+r(4)/2-y)*scale+y);
        end
        
    case 'z_actual' % Actual image size
        this.spApi.setMagnification(1);
        
    case 'p_left'   % Pan left
        r = this.spApi.getVisibleImageRect();
        this.spApi.setVisibleLocation(r(1)-0.1*r(3), r(2));
        
    case 'p_right'  % Pan right
        r = this.spApi.getVisibleImageRect();
        this.spApi.setVisibleLocation(r(1)+0.1*r(3), r(2));
        
    case 'p_up'     % Pan up
        r = this.spApi.getVisibleImageRect();
        this.spApi.setVisibleLocation(r(1), r(2)-0.1*r(4));
        
    case 'p_down'   % Pan down
        r = this.spApi.getVisibleImageRect();
        this.spApi.setVisibleLocation(r(1), r(2)+0.1*r(4));
end
end

