%HIDEPANEL Hide panel 

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function hidePanel(this, tag)
% Make menu item and toggle tool unchecked
set(findobj('Type', 'uimenu', 'Tag', tag), 'Checked', 'off');
set(findobj('Type', 'uitoggletool', 'Tag', tag), 'State', 'off');

% Hide the panel and update position of others
p = this.panels.(tag);
set(p, 'Visible', 'off');

this.openPanels(this.openPanels == p) = [];
