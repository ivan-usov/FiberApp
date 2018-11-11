%REMOVEFIBER "Remove Fiber" menu item callback

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function RemoveFiber(hObject, eventdata)
FA = guidata(hObject);

% Check if there is selected fiber
if FA.sel == 0; return; end

% Delete fiber data from memory
FA.curIm.xy(FA.sel) = [];
FA.curIm.z(FA.sel) = [];

% Delete fiber rectangle from memory
FA.fibRect(:,FA.sel) = [];

% Delete line from an image
delete(FA.fibLine(FA.sel));
FA.fibLine(FA.sel) = [];

% Delete fiber mask from memory
FA.curIm.mask(FA.sel) = [];

% Delete fiber mask from an image
delete(FA.maskLine);
FA.maskLine = [];

% Drop selection number
FA.sel = 0;

% Data is modified
FA.isDataModified = true;
