%GETCOLORMAP Return a 256-color colormap corresponding to a string input

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function map = getColorMap(type)
switch type
    case 'gray'
        map = gray(256);
    case 'jet'
        map = jet(256);
    case 'hsv'
        map = hsv(256);
	case 'bone'
        map = bone(256);
    case 'hot'
        map = hot(256);
    case 'cool'
        map = cool(256);
    case 'copper'
        map = copper(256);
    case 'pink'
        map = pink(256);
    case 'spring'
        map = spring(256);
    case 'summer'
        map = summer(256);
	case 'autumn'
        map = autumn(256);
    case 'winter'
        map = winter(256);
end
