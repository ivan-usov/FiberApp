function ShowHidePanel(hObject, eventdata)
% Function for controling appearance of the menu and toolbar elements upon
% panel opening and closing

tag = get(hObject, 'Tag');
FA = guidata(gcf);
switch get(hObject, 'Type')
    case 'uimenu'
        if strcmp(get(hObject, 'Checked'), 'off')
            FA.showPanel(tag);
        else
            FA.hidePanel(tag);
        end
        
    case 'uitoggletool'
        % MATLAB changes 'State' before executing the callback, so the
        % string is compared to 'on'
        if strcmp(get(hObject, 'State'), 'on')
            FA.showPanel(tag);
        else
            FA.hidePanel(tag);
        end
end

