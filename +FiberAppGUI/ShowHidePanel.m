%SHOWHIDEPANEL A callback to show and close panels via their menu and toolbar items

function ShowHidePanel(hObject, eventdata)
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
