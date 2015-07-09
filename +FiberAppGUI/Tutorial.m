% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
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

