%ZINTERPOLATION "Z Interpolation" menu item callback

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function ZInterpolation(hObject, eventdata)

FA = guidata(hObject);
FA.zInterpMethod = get(hObject, 'Label');

set(get(get(hObject, 'Parent'), 'Children'), 'Checked', 'off');
set(hObject, 'Checked', 'on');
