%TUTORIAL "Tutorial" menu item callback

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function Tutorial(hObject, eventdata)
FA = guidata(hObject);

if FA.isTutorial == true
    FA.isTutorial = false;
    set(hObject, 'Checked', 'off');
else
    FA.isTutorial = true;
    set(hObject, 'Checked', 'on');
    
    FA.tutorial('tutorial_is_on');
end
