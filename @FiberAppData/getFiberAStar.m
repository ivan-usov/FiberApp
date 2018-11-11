%GETFIBERASTAR Get A* path coordinates from a mouse input

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function [xdata, ydata] = getFiberAStar(this)
% Save main key and button functions
kpf_main = get(gcf, 'KeyPressFcn');
wbdf_main = get(gcf, 'WindowButtonDownFcn');
wbuf_main = get(gcf, 'WindowButtonUpFcn');
wbmf_main = get(gcf, 'WindowButtonMotionFcn');

set(gcf, 'Pointer', 'crosshair', ...
    'KeyPressFcn', @kpf, ...
    'WindowButtonDownFcn', @wbdf, ...
    'WindowButtonUpFcn', '', ...
    'WindowButtonMotionFcn', @wbmf);

% Initialise data and creating "empty" dashed line
xdata = [];
ydata = [];
hline = line('XData', xdata, 'YData', ydata, 'LineStyle', ':', ...
    'Color', this.selFiberColor, 'LineWidth', this.selFiberWidth);

cp = get(gca, 'CurrentPoint');
marker = line('XData', round(cp(1,1)), 'YData', round(cp(1,2)), ...
    'Marker', '+', 'Color', this.selFiberColor);
seg_length = [];

% Wait untill "resume" function call
uiwait;

% WindowKeyPressFcn
    function kpf(hObject, eventdata)
        eventchar = uint8(eventdata.Character);
        if isempty(eventchar); return; end
        switch eventchar
            case 8 % Backspace
                % Delete the last point
                if ~isempty(seg_length)
                    xdata(end-seg_length(end)+1:end) = [];
                    ydata(end-seg_length(end)+1:end) = [];
                    seg_length(end) = [];
                    % Refresh the dashed line and delete the last placed marker
                    set(hline, 'XData', xdata, 'YData', ydata);
                    delete(marker(end-1));
                    marker(end-1) = [];
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
                % Delete a whole fiber and resume
                xdata = [];
                ydata = [];
                resume(hObject);
        end
    end

% WindowButtonMotionFunction
    function wbmf(hObject, eventdata)
        % Get coordinates of the mouse cursor
        cp = get(gca, 'CurrentPoint');
        x = round(cp(1,1));
        y = round(cp(1,2));
        
        % Check for the visible border conditions
        r = this.spApi.getVisibleImageRect();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y); return; end
        
        % Refresh the marker
        set(marker(end), 'XData', x, 'YData', y);
    end

% WindowButtonDownFunction
    function wbdf(hObject, eventdata)
        cp = get(gca, 'CurrentPoint');
        x = round(cp(1,1));
        y = round(cp(1,2));
        
        % Check for visible border conditions
        r = this.spApi.getVisibleImageRect();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y); return; end
        
        if isempty(xdata) % first click
            xdata = x;
            ydata = y;
            
            % Refresh the last marker and add a new one
            set(marker(end), 'XData', x, 'YData', y);
            marker(end+1) = line('XData', x, 'YData', y, ...
                'Marker', '+', 'Color', this.selFiberColor);
            
        elseif x ~= xdata(end) || y ~= ydata(end) % calculate path
            [xi, yi] = utility.searchPath(this.im, this.fiberIntensity*0.607, ...
                xdata(end), ydata(end), x, y);
            
            % If we couldn't find a path
            if isempty(xi)
                xdata = [];
                ydata = [];
                resume(hObject);
                errordlg('Could not find a path', 'A* Error');
                return
            end
            
            xdata = [xdata, xi(2:end)];
            ydata = [ydata, yi(2:end)];
            seg_length(end+1) = length(xi) - 1;
            set(hline, 'XData', xdata, 'YData', ydata);
            
            % Refresh the last marker and add a new one
            set(marker(end), 'XData', x, 'YData', y);
            marker(end+1) = line('XData', x, 'YData', y, ...
                'Marker', '+', 'Color', this.selFiberColor);
        end
        
        % Check for mouse right click
        if strcmp(get(hObject, 'SelectionType'), 'alt')
            resume(hObject);
        end
    end

% Resume
    function resume(hObject)
        % Replace back key and button functions
        set(hObject, 'Pointer', 'arrow', ...
            'KeyPressFcn', kpf_main, ...
            'WindowButtonDownFcn', wbdf_main, ...
            'WindowButtonUpFcn', wbuf_main, ...
            'WindowButtonMotionFcn', wbmf_main);
        % Delete dashed line and all markers
        delete(hline);
        delete(marker);
        % Resume program's main stream execution
        uiresume;
    end
end
