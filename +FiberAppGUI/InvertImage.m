% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function InvertImage(hObject, eventdata)

FA = guidata(hObject);

% Invert image
FA.im = max(FA.im(:)) + min(FA.im(:)) - FA.im;
FA.updateImage('PreserveContrast', 'PreserveView');

