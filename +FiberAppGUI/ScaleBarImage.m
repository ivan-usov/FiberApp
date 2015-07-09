% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function ScaleBarImage(hObject, eventdata)
FA = guidata(hObject);

% Promote a user to specify a scale bar length in pix
scaleBar_pix = FA.getScaleBarLineLength;
if isempty(scaleBar_pix); return; end

% Promote a user to specify a scale bar length in nm
scaleBar_nm = abs(real(str2double(inputdlg('Scale Bar size (nm):'))));
if isempty(scaleBar_nm); return; end % Cancel button pressed
if isnan(scaleBar_nm) % Input is not scalar
    errordlg('Invalid input.', 'Scale Bar');
    return
end

% Calculate image parameters
FA.scaleXY = scaleBar_nm/scaleBar_pix;
FA.sizeX_nm = round(FA.scaleXY*(FA.sizeX-1));
FA.sizeY_nm = round(FA.scaleXY*(FA.sizeY-1));

% Calculate suggested proper step for tracking algorithm
FA.step_nm = utility.round2n(3*FA.scaleXY);
FA.step = FA.step_nm/FA.scaleXY;

FA.checkAccordance();

