%GETMASK Get mask coordinates from a mouse input 

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function [xdata, ydata, size] = getMask(this)
% Save main key and button function
kpf_main = get(gcf, 'KeyPressFcn');
wbdf_main = get(gcf, 'WindowButtonDownFcn');
wbuf_main = get(gcf, 'WindowButtonUpFcn');
wbmf_main = get(gcf, 'WindowButtonMotionFcn');

set(gcf, 'Pointer', 'crosshair', ...
    'KeyPressFcn', @kpf, ...
    'WindowButtonDownFcn', @wbdf, ...
    'WindowButtonUpFcn', '', ...
    'WindowButtonMotionFcn', @wbmf);

% Initialise data
xdata = [];
ydata = [];
size = [];
cp = get(gca, 'CurrentPoint');
hrect = rectangle('Position', ...
    [cp(1,1)-this.maskSize/2, cp(1,2)-this.maskSize/2, this.maskSize, this.maskSize], ...
    'LineStyle', ':', 'EdgeColor', this.maskLineColor, 'LineWidth', this.maskLineWidth);

% Wait untill "resume" function call
uiwait;

% WindowKeyPressFcn
    function kpf(hObject, eventdata)
        eventchar = uint8(eventdata.Character);
        if isempty(eventchar); return; end
        switch eventchar
            case 8 % Backspace
                if ~isempty(xdata)
                    % Delete last rectangle
                    delete(hrect(end-1));
                    hrect(end-1) = [];
                    xdata(end) = [];
                    ydata(end) = [];
                    size(end) = [];
                end
                
            case 28 % Leftarrow
                this.pan_zoom('p_left');
                
            case 29 % Rightarrow
                this.pan_zoom('p_right');
                
            case 30 % Uparrow
                this.pan_zoom('p_up');
                
            case 31 % Downarrow
                this.pan_zoom('p_down');
                
            case 127 % Delete
                % Delete all data and resume
                xdata = [];
                ydata = [];
                size = [];
                resume(hObject);
        end
    end

% WindowButtonMotionFunction
    function wbmf(hObject, eventdata)
        % Get coordinates of the mouse cursor
        cp = get(gca, 'CurrentPoint');
        x = cp(1,1);
        y = cp(1,2);
        
        % Check for visible border conditions
        r = this.spApi.getVisibleImageRect();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y); return; end
        
        % Rectangle reposition
        set(hrect(end), 'Position', ...
            [x-this.maskSize/2, y-this.maskSize/2, this.maskSize, this.maskSize]);
    end

% WindowButtonDownFunction
    function wbdf(hObject, eventdata)
        cp = get(gca, 'CurrentPoint');
        x = cp(1,1);
        y = cp(1,2);
        
        % Check for visible border conditions
        r = this.spApi.getVisibleImageRect();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y); return; end
        
        xdata = [xdata x];
        ydata = [ydata y];
        size = [size this.maskSize];
        
        % Check for mouse right click
        if strcmp(get(hObject, 'SelectionType'), 'alt')
            resume(hObject);
            return
        end
        
        % Create new rectangle
        hrect = [hrect rectangle('Position', ...
            [x-this.maskSize/2, y-this.maskSize/2, this.maskSize, this.maskSize], ...
            'LineStyle', ':', 'EdgeColor', this.maskLineColor, ...
            'LineWidth', this.maskLineWidth)];
    end

% Resume
    function resume(hObject)
        % Clean mouse button functions and resume program
        set(hObject, 'Pointer', 'arrow', ...
            'KeyPressFcn', kpf_main, ...
            'WindowButtonDownFcn', wbdf_main, ...
            'WindowButtonUpFcn', wbuf_main, ...
            'WindowButtonMotionFcn', wbmf_main);
        delete(hrect);
        % Resume program's main stream execution
        uiresume;
    end
end
