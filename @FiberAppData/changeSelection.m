function changeSelection(this, val)
% Return if the selection is on already selected fiber or selection was
% dropped (val == 0)
if val == this.sel || val == 0; return; end

% Change appearance of a previously selected fiber if it still exists
if this.sel ~= 0
    switch this.fiberStyle
        case 1 % 'line'
            set(this.fibLine(this.sel), 'Marker', 'none', 'LineStyle', '-');
        case 2 % 'point'
            set(this.fibLine(this.sel), 'Marker', '.', 'LineStyle', 'none');
    end
    set(this.fibLine(this.sel), 'Color', this.fiberColor, 'LineWidth', this.fiberWidth);
    
    delete(this.maskLine);
    this.maskLine = [];
end

% Change appearance of a newly selected fiber
switch this.selFiberStyle
    case 1 % 'line'
        set(this.fibLine(val), 'Marker', 'none', 'LineStyle', '-');
    case 2 % 'point'
        set(this.fibLine(val), 'Marker', '.', 'LineStyle', 'none');
end
set(this.fibLine(val), 'Color', this.selFiberColor, 'LineWidth', this.selFiberWidth);

% Arrange masks appearance
m = this.curIm.mask{val};
if ~isempty(m)
    this.maskLine = arrayfun(@(mx,my,ms) rectangle('Parent', this.spAxes, ...
        'Position',  [mx-ms/2, my-ms/2, ms, ms], 'EdgeColor', this.maskLineColor, ...
        'LineWidth', this.maskLineWidth),  m(1,:), m(2,:), m(3,:));
end

