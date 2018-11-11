%ZOOM Zoom-related menu items callback

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function Zoom(hObject, eventdata, dir)
FA = guidata(hObject);
switch dir
    case 'in'
        FA.pan_zoom('z_in');
    case 'out'
        FA.pan_zoom('z_out');
    case 'actual'
        FA.pan_zoom('z_actual');
end
