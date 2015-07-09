% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function len = getScaleBarLineLength(this)
% GETSCALEBARLINELENGTH Get horizontal or vertical scale bar line with mouse input

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

% Initialise data and create an "empty" line
len = [];
x1 = [];
y1 = [];
hline = line('XData', x1, 'YData', y1, ...
    'Color', this.scaleBarColor, 'LineWidth', this.scaleBarWidth);

% Wait untill "resume" function call
uiwait;

% WindowKeyPressFcn
    function kpf(hObject, eventdata)
        eventchar = uint8(eventdata.Character);
        if isempty(eventchar); return; end
        switch eventchar
            case 8 % Backspace
                % Clear the initial point and hide the line
                x1 = [];
                y1 = [];
                set(hline, 'XData', x1, 'YData', y1);
                
            case 28 % Leftarrow
                this.pan_zoom('p_left');
                
            case 29 % Rightarrow
                this.pan_zoom('p_right');
                
            case 30 % Uparrow
                this.pan_zoom('p_up');
                
            case 31 % Downarrow
                this.pan_zoom('p_down');
                
            case 127 % Delete
                % Abort
                resume(hObject);
        end
    end

% WindowButtonMotionFunction
    function wbmf(hObject, eventdata)
        % Abort in case there was no first mouse left click yet
        if isempty(x1); return; end
        
        % Get coordinates of the mouse cursor
        cp = get(gca, 'CurrentPoint');
        x = cp(1,1);
        y = cp(1,2);
        
        % Check for visible border conditions
        r = this.spApi.getVisibleImageRect();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y); return; end
        
        % Refresh the line
        if abs(x1-x) < abs(y1-y)
            set(hline, 'XData', [x1, x1], 'YData', [y1, y]);
        else
            set(hline, 'XData', [x1, x], 'YData', [y1, y1]);
        end
        
    end

% WindowButtonDownFunction
    function wbdf(hObject, eventdata)
        cp = get(gca, 'CurrentPoint');
        x = cp(1,1);
        y = cp(1,2);
        
        % Check for visible border conditions
        r = this.spApi.getVisibleImageRect();
        if (x<r(1) || r(1)+r(3)<x || y<r(2) || r(2)+r(4)<y); return; end
        
        % Check for the mouse right click
        if strcmp(get(hObject, 'SelectionType'), 'alt')
            % Abort
            resume(hObject);
            return;
        end
        
        % In case of the first left click
        if isempty(x1)
            x1 = x;
            y1 = y;
        % In case of the second left click
        elseif x ~= x1(end) || y ~= y1(end)
            len = max(abs(x-x1), abs(y-y1));
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
        
        % Delete the line
        delete(hline);
        
        % Resume program's main stream execution
        uiresume;
    end
end

