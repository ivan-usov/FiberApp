function ShowHidePanel(hObject, eventdata)

switch get(hObject, 'Type')
    case 'uimenu'
        if strcmp(get(hObject, 'Checked'), 'off')
            panel.show(hObject, eventdata);
        else
            panel.hide(hObject, eventdata);
        end
        
    case 'uitoggletool'
        % MATLAB changes 'State' before executing the callback, so the
        % string is compared to 'on'
        if strcmp(get(hObject, 'State'), 'on')
            panel.show(hObject, eventdata);
        else
            panel.hide(hObject, eventdata);
        end
end

