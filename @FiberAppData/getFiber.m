function [xdata, ydata] = getFiber(this)
% GETFIBER Get line coordinates with mouse input

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
cp = get(gca, 'CurrentPoint');
hline = line('XData', cp(1,1), 'YData', cp(1,2), 'LineStyle', ':', 'Marker', '+', ...
    'Color', this.selFiberColor, 'LineWidth', this.selFiberWidth);

% Wait untill "resume" function call
uiwait;

% WindowKeyPressFcn
    function kpf(hObject, eventdata)
        eventchar = uint8(eventdata.Character);
        if isempty(eventchar); return; end
        switch eventchar
            case 8 % Backspace
                % Delete the last point
                if length(xdata) > 1
                    xdata(end) = [];
                    ydata(end) = [];
                    % Refresh the dashed line
                    wbmf(hObject, eventdata);
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
        x = cp(1,1);
        y = cp(1,2);
        
        % Check for visible border conditions
        r = this.spApi.getVisibleImageRect();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y); return; end
        
        % Refresh the dashed line
        set(hline, 'XData', [xdata x], 'YData', [ydata y]);
    end

% WindowButtonDownFunction
    function wbdf(hObject, eventdata)
        cp = get(gca, 'CurrentPoint');
        x = cp(1,1);
        y = cp(1,2);
        
        % Check for visible border conditions
        r = this.spApi.getVisibleImageRect();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y); return; end
        
        % Check for doubled points. If OK, add coordinates to data.
        if isempty(xdata) || x ~= xdata(end) || y ~= ydata(end)
            xdata = [xdata x];
            ydata = [ydata y];
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
        % Delete dashed line
        delete(hline);
        % Resume program's main stream execution
        uiresume;
    end
end

