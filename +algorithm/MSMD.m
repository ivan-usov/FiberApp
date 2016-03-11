function [xdata, ydata, count] = MSMD(data, step, procStepNum)
%MSMIDPOINTDISPLACEMENT Mean-Square Midpoint Displacement

xdata = step*(1:procStepNum);
ydata = zeros(1, procStepNum); % MS midpoint displacement
count = zeros(1, procStepNum); % weight of each graph point

for k = 1:length(data)
    xy = data{k}; % coordinates of the current fiber
    
    n = length(xy); % number of points in the current fiber
    
    shiftNum = min(procStepNum, floor((n-1)/2));
    
    count(1:shiftNum) = count(1:shiftNum) + (n-2:-2:n-2*shiftNum);
    
    % Cycle for different separations between points along a fiber
    for l = 1:shiftNum
        val1 = xy(:,1:end-2*l) - xy(:,1+2*l:end);
        val2 = xy(:,1+l:end-l) - xy(:,1:end-2*l);
        ydata(l) = ydata(l) + ...
            sum( diff( val1 .* val2(2:-1:1,:) ).^2 ./ sum(val1.^2) );
    end
end

ydata = ydata./count;

