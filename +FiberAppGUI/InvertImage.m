%INVERTIMAGE "Invert Image" menu item callback

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function InvertImage(hObject, eventdata)

FA = guidata(hObject);

% Invert image
FA.im = max(FA.im(:)) + min(FA.im(:)) - FA.im;
FA.updateImage('PreserveContrast', 'PreserveView');
