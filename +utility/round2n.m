%ROUND2N Round a number up to two significant digits

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function out = round2n(in)
if in == 0
    out = 0;
    return
end

i = 0;

while(abs(in) < 10)
    i = i-1;
    in = in*10;
end

while(abs(in) > 100)
    i = i+1;
    in = in/10;
end

out = round(in)*10.^i;
