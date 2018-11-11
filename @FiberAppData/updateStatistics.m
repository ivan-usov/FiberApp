%UPDATESTATISTICS Update statistics on the corresponding panel

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function updateStatistics(this)
% Number of images
set(findobj('Tag', 't_nIm'), 'String', length(this.imageData));

% Number of fibers: current image
if isempty(this.curIm)
    nFibCur = 0;
else
    nFibCur = length(this.curIm.xy);
end
set(findobj('Tag', 't_nFibCur'), 'String', nFibCur);

% Number of fibers: total
if isempty(this.imageData)
    nFibTot = 0;
else
    nFibTot = sum(cellfun(@length, {this.imageData.xy}));
end
set(findobj('Tag', 't_nFibTot'), 'String', nFibTot);

% Selected fiber: length, average height
if this.sel == 0
    fibLen = [];
    fibAvh = [];
else
    fibLen = this.curIm.length_nm(this.sel);
    fibAvh = this.curIm.height_nm(this.sel);
end
set(findobj('Tag', 't_fibLen'), 'String', fibLen);
set(findobj('Tag', 't_fibAvh'), 'String', fibAvh);
