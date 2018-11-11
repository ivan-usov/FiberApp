%RENDERFIBERS  Render fibers within a visible rectangle

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function renderFibers(this, varargin)

if isempty(this.fibRect); return; end
ir = this.spApi.getVisibleImageRect();
ir(3) = ir(1) + ir(3);
ir(4) = ir(2) + ir(4);
ind = min(this.fibRect(3,:),ir(3)) > max(this.fibRect(1,:),ir(1)) & ...
    min(this.fibRect(4,:),ir(4)) > max(this.fibRect(2,:),ir(2));
set(this.fibLine(ind), 'Visible', 'on');
set(this.fibLine(~ind), 'Visible', 'off');
