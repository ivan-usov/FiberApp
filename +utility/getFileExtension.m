%GETFILEEXTENSION Extract extension of a file

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function ext = getFileExtension(fileName)
ind = find(fileName == '.', 1, 'last');
if isempty(ind)
    ext = '';
else
    ext = lower(fileName(ind+1:end));
end
