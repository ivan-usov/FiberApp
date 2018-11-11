%BCF Calculate bond correlation function

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function [xdata, ydata, count] = BCF(data, step, procStepNum)
xdata = step*(1:procStepNum);
ydata = zeros(1, procStepNum); % <cos(\theta(l))>
count = zeros(1, procStepNum); % weight of each graph point

for k = 1:length(data)    
    vect = diff(data{k}, 1, 2);
    leng = sqrt(sum(vect.^2));
    vect = vect./[leng; leng]; % normalized vectors
    
    n = length(vect); % number of vectors in the current fiber
    
    shiftNum = min(procStepNum, n-1);
    
    count(1:shiftNum) = count(1:shiftNum) + (n-1:-1:n-shiftNum);
    
    % Cycle for different separations between vectors along a fiber
    for l = 1:shiftNum
        ydata(l) = ydata(l) + ...
            sum( sum( vect(:,1:end-l) .* vect(:,1+l:end) ) );
    end
end

ydata = ydata./count;
