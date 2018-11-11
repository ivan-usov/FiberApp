%REMOVESURFACEIMAGE "Remove Surface" menu item callback

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function RemoveSurfaceImage(hObject, eventdata)

FA = guidata(hObject);
hwb = waitbar(0.1, 'Please wait...', 'WindowStyle', 'modal', 'CloseRequestFcn', '');
% Tophat filter (remove surface)
FA.im = imtophat(FA.im, strel('square', 75));
waitbar(0.9);
FA.updateImage('PreserveView');
delete(hwb);
