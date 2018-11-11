%SHOWPANEL Show panel

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function showPanel(this, tag)

% Make menu item and toggle tool checked
set(findobj('Type', 'uimenu', 'Tag', tag), 'Checked', 'on');
set(findobj('Type', 'uitoggletool', 'Tag', tag), 'State', 'on');

% Show the panel and update position
p = this.panels.(tag);
set(p, 'Visible', 'on');

this.openPanels(end+1) = p;
