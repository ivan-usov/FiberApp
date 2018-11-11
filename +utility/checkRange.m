%CHECKRANGE Parse minimal and maximal range values

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function [rMin, rMax] = checkRange(rMin, rMax, data)
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
