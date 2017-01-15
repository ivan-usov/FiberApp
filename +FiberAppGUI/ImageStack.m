function ImageStack(hObject, eventdata, dir)
% Possible operations with image stacks

FA = guidata(hObject);
switch dir
    case 'next'
        if FA.imageStackPos < FA.imageStackSize
            FA.imageStackPos = FA.imageStackPos+1;
            FA.im = FA.imageStack(:, :, FA.imageStackPos);
        end
        
    case 'prev'
        if FA.imageStackPos > 1
            FA.imageStackPos = FA.imageStackPos-1;
            FA.im = FA.imageStack(:, :, FA.imageStackPos);
        end
end

FA.updateImage();
FA.checkAccordance();

% Put main window in a focus
figure(gcf);

