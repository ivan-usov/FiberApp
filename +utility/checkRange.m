function [rMin, rMax] = checkRange(rMin, rMax, data)
%CHECKRANGE Check rangeMin and rangeMax values

if isempty(rMin)
    rMin = utility.floor2n(min(data));
end

if isempty(rMax)
    rMax = utility.ceil2n(max(data));
end

if rMin >= rMax
    rMin = utility.floor2n(min(data));
    rMax = utility.ceil2n(max(data));
end

