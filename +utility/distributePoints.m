function outXY = distributePoints(inXY, step)
%DISTRIBUTE_POINTS Distribute equally spaced points along the curve

% Coordinates of vectors between consecutive points
vect = diff(inXY, 1, 2);

% Lengths of vectors (distances between consecutive points)
vectLen = sqrt(sum(vect.^2));

% Parametric coordinates of points along the old curve
pcOld = [0 cumsum(vectLen)];

% Number of vectors (segments) in a new curve
vectNum = round(pcOld(end)/step);

% Minimum number of vectors must be 3
if vectNum < 3; vectNum = 3; end

% Tail (the same length at both ends)
tail = (pcOld(end)-vectNum*step)/2;

% Parametric coordinates of new points along the old curve
pcNew = linspace(tail, pcOld(end)-tail, vectNum+1);

% Vectors indexes of the old curve, that contain points of the new curve 
[~, bin] = histc(pcNew, pcOld);
bin(end) = bin(end-1);
bin(bin == 0) = 1;

% Normalized parametric coordinates of the new points related to the
% vectors, that contain these points
pcNew = (pcNew-pcOld(bin))./vectLen(bin);

% Coordinates of the new curve
outXY = inXY(:,bin) + vect(:,bin).*[pcNew; pcNew];

