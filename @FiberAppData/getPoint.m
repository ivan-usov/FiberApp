%GETPOINT Get point coordinates from a mouse input

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function [xdata, ydata] = getPoint(this)
% Save main key and button function
kpf_main = get(gcf, 'KeyPressFcn');
wbdf_main = get(gcf, 'WindowButtonDownFcn');
wbuf_main = get(gcf, 'WindowButtonUpFcn');
wbmf_main = get(gcf, 'WindowButtonMotionFcn');

set(gcf, 'Pointer', 'crosshair', ...
    'KeyPressFcn', @kpf, ...
    'WindowButtonDownFcn', @wbdf, ...
    'WindowButtonUpFcn', '', ...
    'WindowButtonMotionFcn', '');

% Initialise data
xdata = [];
ydata = [];

% Wait untill "resume" function call
uiwait;

% WindowKeyPressFcn
    function kpf(hObject, eventdata)
        eventchar = uint8(eventdata.Character);
        if isempty(eventchar); return; end
        switch eventchar
            case 28 % Leftarrow
                this.pan_zoom('p_left');
                
            case 29 % Rightarrow
                this.pan_zoom('p_right');
                
            case 30 % Uparrow
                this.pan_zoom('p_up');
                
            case 31 % Downarrow
                this.pan_zoom('p_down');
        end
    end

% WindowButtonDownFunction
    function wbdf(hObject, eventdata)
        cp = get(gca, 'CurrentPoint');
        x = round(cp(1,1));
        y = round(cp(1,2));
        
        % Check for visible border conditions
        r = this.spApi.getVisibleImageRect();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y); return; end
        
        % Check for mouse left click
        if strcmp(get(hObject, 'SelectionType'), 'normal')
            xdata = x;
            ydata = y;
        end
        
        % Clean mouse button functions and resume program
        set(hObject, 'Pointer', 'arrow', ...
            'KeyPressFcn', kpf_main, ...
            'WindowButtonDownFcn', wbdf_main, ...
            'WindowButtonUpFcn', wbuf_main, ...
            'WindowButtonMotionFcn', wbmf_main);
        % Resume program's main stream execution
        uiresume;
    end
end
