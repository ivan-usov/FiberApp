function p = FiberImageGenerator
ph = 333; % panel height
pTitle = 'Fiber/Image Generator';
pTag = 'FiberImageGenerator';
% Panel and hide button
p = uipanel(gcf, 'Units', 'pixels', 'FontWeight', 'bold', ...
    'BorderType', 'line', 'HighlightColor', [0.5 0.5 0.5], ...
    'Visible', 'off', ...
    'Title', pTitle, ...
    'Tag', pTag, ...
    'Position', [0 0 230 ph]);
FA = guidata(gcf);
uicontrol(p, 'Style', 'pushbutton', 'String', '-', ...
    'HitTest', 'off', ...
    'Callback', @(h,ed) FA.hidePanel(pTag), ...
    'Position', [211 ph-30 18 16]);
% Panel components --------------------------------------------------------
% Length distribution
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Length distribution', ...
    'Position', [10 ph-38 100 14]);
ui.distrib = uicontrol(p, 'Style', 'popup', 'BackgroundColor', [1 1 1], ...
    'String', {'Normal', 'Lognormal', 'Exponential'}, ...
    'UserData', 1, ... % Current choice
    'Callback', @FiberImageGenerator_LengthDistribution, ...
    'Position', [135 ph-42 75 22]);
% --- mu
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'mu:', ...
    'Position', [15 ph-61 100 14]);
ui.t_nm = uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-61 35 14]);
ui.mu = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', '1000', ...
    'Position', [135 ph-65 51 22]);
% --- sigma
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'sigma:', ...
    'Position', [15 ph-84 100 14]);
ui.t2_nm = uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-84 35 14]);
ui.sigma = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', '0', ...
    'Position', [135 ph-88 51 22]);
% Persistence length
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Persistence length:', ...
    'Position', [10 ph-107 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-107 35 14]);
ui.fibLp = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', '700', ...
    'Position', [135 ph-111 51 22]);
% Step size
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Step size:', ...
    'Position', [10 ph-130 100 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-130 35 14]);
ui.fibStep = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', '3', ...
    'Position', [135 ph-134 51 22]);
% Radius
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Radius:', ...
    'Position', [10 ph-153 150 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-153 35 14]);
ui.fibRad = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', '4', ...
    'Position', [135 ph-157 51 22]);
% Total number
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Total number:', ...
    'Position', [10 ph-176 100 14]);
ui.fibNum = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'String', '300', ...
    'Position', [135 ph-180 51 22]);
% Scatter fibers and save an image
ui.genImage = uicontrol(p, 'Style', 'checkbox', 'Value', 0, ...
    'String', 'Scatter fibers and generate an image', ...
    'Callback', @FiberImageGenerator_GenerateImage, ...
    'Position', [10 ph-203 200 20]);
% Image size (square box)
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Image size (square box):', ...
    'Position', [10 ph-226 150 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'pix', ...
    'Position', [188 ph-226 35 14]);
ui.imSize = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'Enable', 'off', ...
    'String', '5120', ...
    'Position', [135 ph-230 51 22]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-249 35 14]);
ui.imSize_nm = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'Enable', 'off', ...
    'String', '15000', ...
    'Position', [135 ph-253 51 22]);
% AFM tip radius
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'AFM tip radius:', ...
    'Position', [10 ph-272 150 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-272 35 14]);
ui.tipRad = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'Enable', 'off', ...
    'String', '5', ...
    'Position', [135 ph-276 51 22]);
% Z intensity step
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'Z intensity step:', ...
    'Position', [10 ph-295 150 14]);
uicontrol(p, 'Style', 'text', 'HorizontalAlignment', 'left', ...
    'String', 'nm', ...
    'Position', [188 ph-295 35 14]);
ui.zStep = uicontrol(p, 'Style', 'edit', 'HorizontalAlignment', 'left', ...
    'BackgroundColor', [1 1 1], ...
    'Enable', 'off', ...
    'String', '0.1', ...
    'Position', [135 ph-299 51 22]);
% Generate button
uicontrol(p, 'Style', 'pushbutton', ...
    'String', 'Generate', ...
    'Callback', @FiberImageGenerator_Generate, ...
    'Position', [135 ph-323 70 22]);
% Save ui elements as 'UserData' of the panel
set(p, 'UserData', ui);
end

function FiberImageGenerator_LengthDistribution(hObject, eventdata)
% Return if a new user choce same as a last one
val = get(hObject, 'Value');
if val == get(hObject, 'UserData'); return; end
set(hObject, 'UserData', val);

% Get parameters from the panel
ui = get(get(hObject, 'Parent'), 'UserData');
mu_old = abs(sscanf(get(ui.mu, 'String'), '%f', 1));
sigma_old = abs(sscanf(get(ui.sigma, 'String'), '%f', 1));

switch val
    case 1 % Normal
        mu_new = exp(mu_old+sigma_old^2/2);
        sigma_new = exp(2*mu_old+sigma_old^2)*(exp(sigma_old^2)-1);
        set([ui.t_nm, ui.t2_nm], 'String', 'nm');
    case 2 % Lognormal
        mu_new = log(mu_old^2/sqrt(sigma_old+mu_old^2));
        sigma_new = sqrt(log(1+sigma_old/mu_old^2));
        set([ui.t_nm, ui.t2_nm], 'String', '');
    case 3 % Exponential
        mu_new = mu_old;
        sigma_new = sigma_old;
        set([ui.t_nm, ui.t2_nm], 'String', 'nm');
end
set(ui.mu, 'String', mu_new);
set(ui.sigma, 'String', sigma_new);
end

function FiberImageGenerator_GenerateImage(hObject, eventdata)
ui = get(get(hObject, 'Parent'), 'UserData');
if get(hObject, 'Value') == get(hObject, 'Max')
    set([ui.imSize, ui.imSize_nm, ui.tipRad, ui.zStep], 'Enable', 'on');
else
    set([ui.imSize, ui.imSize_nm, ui.tipRad, ui.zStep], 'Enable', 'off');
end
end

function FiberImageGenerator_Generate(hObject, eventdata)
% Get parameters from the panel for generation
ui = get(get(hObject, 'Parent'), 'UserData');
mu = abs(sscanf(get(ui.mu, 'String'), '%f', 1));
sigma = abs(sscanf(get(ui.sigma, 'String'), '%f', 1));
fibLp = abs(sscanf(get(ui.fibLp, 'String'), '%f', 1));
fibStep_nm = abs(sscanf(get(ui.fibStep, 'String'), '%f', 1));
fibRad = abs(sscanf(get(ui.fibRad, 'String'), '%f', 1));
fibNum = abs(sscanf(get(ui.fibNum, 'String'), '%d', 1));

% Refresh actual parameters in edit boxes
set(ui.mu, 'String', mu);
set(ui.sigma, 'String', sigma);
set(ui.fibLp, 'String', fibLp);
set(ui.fibStep, 'String', fibStep_nm);
set(ui.fibRad, 'String', fibRad);
set(ui.fibNum, 'String', fibNum);

% Disable the button
set(hObject, 'Enable', 'off', 'String', 'Processing');
drawnow update;

% Calculate length in steps for all fibers and average length in nm
switch get(ui.distrib, 'Value')
    case 1 % Normal
        l = round(random('Normal', mu, sigma, [1, fibNum])/fibStep_nm);
        l_avg = mu;
    case 2 % Lognormal
        l = round(random('Lognormal', mu, sigma, [1, fibNum])/fibStep_nm);
        l_avg = exp(mu+sigma.^2/2);
    case 3 % Exponential
        l = round(random('Exponential', mu, [1, fibNum])/fibStep_nm);
        l_avg = mu;
end

if get(ui.genImage, 'Value') == get(ui.genImage, 'Min') % generate only fibers
    % Generate XYZ coordinates along the fibers
    xy = cell(1, fibNum);
    z = cell(1, fibNum);
    st = sqrt(fibStep_nm/fibLp); % sigma_theta
    ac = random('Uniform', 0, 2*pi, [1, fibNum]); % Initial angle directions
    for k = 1:fibNum
        a = cumsum([ac(k), random('Normal', 0, st, [1, l(k)-1])]);
        x = cumsum([0, fibStep_nm*cos(a)]);
        y = cumsum([0, fibStep_nm*sin(a)]);
        xy{k} = [x; y];
        z{k} = 2*fibRad*ones(1, l(k)+1);
    end
    
    % Create a fiber data
    imageData = ImageData;
    imageData.name = '';
    imageData.sizeX = 1;
    imageData.sizeY = 1;
    imageData.sizeX_nm = 1;
    imageData.sizeY_nm = 1;
    imageData.scaleXY = 1;
    imageData.scaleZ = 1;
    imageData.step = fibStep_nm;
    imageData.step_nm = fibStep_nm;
    imageData.xy = xy;
    imageData.z = z;
    imageData.mask = cell(size(xy));
    
    % Save the fiber data to a file
    [fileName, filePath] = uiputfile('*.mat', 'Save As', 'data_generated');
    if fileName ~= 0
        save(fullfile(filePath, fileName), 'imageData');
    end
    
else % generate fibers and an image
    imSize = abs(sscanf(get(ui.imSize, 'String'), '%d', 1));
    imSize_nm = abs(sscanf(get(ui.imSize_nm, 'String'), '%f', 1));
    tipRad = abs(sscanf(get(ui.tipRad, 'String'), '%f', 1));
    zStep = abs(sscanf(get(ui.zStep, 'String'), '%f', 1));
    
    % Refresh actual parameters in edit boxes
    set(ui.imSize, 'String', imSize);
    set(ui.imSize_nm, 'String', imSize_nm);
    set(ui.tipRad, 'String', tipRad);
    set(ui.zStep, 'String', zStep);
    
    % Check the reasonability of the data
    if sqrt(4*fibLp*(l_avg-2*fibLp*(1-exp(-l_avg/2/fibLp)))) > imSize_nm
        str = {'The average end-to-end distance of fibers', ...
            'is larger than the image size. The image ', ...
            'generation cannot be completed.'};
        errordlg(str, 'Error');
        % Recover the button
        set(hObject, 'Enable', 'on', 'String', 'Generate');
        return
    elseif 4*sqrt(4*fibLp*(l_avg-2*fibLp*(1-exp(-l_avg/2/fibLp)))) > imSize_nm
        str = {'The average end-to-end distance of fibers is', ...
            'larger than 25% of the image size. This might', ...
            'lead to a very long processing time.', ...
            ' ', ...
            'Do you want to continue?'};
        answer = questdlg(str, 'Warning', 'Continue', 'Stop', 'Stop');
        if  ~strcmp(answer, 'Continue')
            % Recover the button
            set(hObject, 'Enable', 'on', 'String', 'Generate');
            return
        end
    end
    
    % Generate XYZ coordinates along the fibers
    xy = cell(1, fibNum);
    z = cell(1, fibNum);
    st = sqrt(fibStep_nm/fibLp); % sigma_theta
    scaleXY = imSize_nm/imSize;
    fibStep = fibStep_nm/scaleXY;
    
    k = 1;
    while k <= fibNum
        % 0.5 is the coordinate of the image's left border
        ac = random('Uniform', 0, 2*pi, 1); % Initial angle direction
        xc = random('Uniform', 0.5, imSize+0.5, 1); % X start point
        yc = random('Uniform', 0.5, imSize+0.5, 1); % Y start point
        
        a = cumsum([ac, random('Normal', 0, st, [1, l(k)-1])]);
        x = cumsum([xc, fibStep*cos(a)]);
        y = cumsum([yc, fibStep*sin(a)]);
        % take only those that are withing the image borders
        if all(x>0.5 & x<imSize+0.5 & y>0.5 & y<imSize+0.5)
            xy{k} = [x; y];
            z{k} = 2*fibRad/zStep*ones(1, l(k)+1);
            k = k + 1;
        end
    end
    
    % Generate an image
    im = zeros(imSize, 'uint8');
    r = (fibRad+tipRad)/scaleXY;
    h = 2*fibRad/zStep;
    for k = 1:length(xy)
        x1 = xy{k}(1,1:end-1);
        x2 = xy{k}(1,2:end);
        y1 = xy{k}(2,1:end-1);
        y2 = xy{k}(2,2:end);
        
        x_min = max(ceil(min([x1; x2])-r), 1);
        x_max = min(floor(max([x1; x2])+r), imSize);
        y_min = max(ceil(min([y1; y2])-r), 1);
        y_max = min(floor(max([y1; y2])+r), imSize);
        
        arrayfun(@im_gen, x1, x2, y1, y2, x_min, x_max, y_min, y_max);
    end
    
    % Save the image and the data to files
    [fileName, filePath] = uiputfile('*.tif', 'Save As', 'image_generated');
    if fileName ~= 0
        % Save the image
        imwrite(im, fullfile(filePath, fileName), 'tif');
        
        % Create a fiber data
        imageData = ImageData;
        imageData.name = fileName;
        imageData.sizeX = imSize;
        imageData.sizeY = imSize;
        imageData.sizeX_nm = imSize_nm;
        imageData.sizeY_nm = imSize_nm;
        imageData.scaleXY = scaleXY;
        imageData.scaleZ = zStep;
        imageData.step = fibStep;
        imageData.step_nm = fibStep_nm;
        imageData.xy = xy;
        imageData.z = z;
        imageData.mask = cell(size(xy));
        
        % Save the fiber data to a file with the same name
        fileName = [fileName(1:end-3), 'mat'];
        save(fullfile(filePath, fileName), 'imageData');
    end
end

% Recover the button
set(hObject, 'Enable', 'on', 'String', 'Generate');

    function im_gen(x1, x2, y1, y2, x_min, x_max, y_min, y_max)
        [xg, yg] = meshgrid(x_min:x_max, y_min:y_max);
        
        d = ((x2-x1).*(yg-y1)-(y2-y1).*(xg-x1)./fibStep).^2;
        
        ind = (x2-x1).*(xg-x1)+(y2-y1).*(yg-y1) < 0;
        d_min = (xg-x1).^2+(yg-y1).^2;
        d(ind) = d_min(ind);
        
        ind = (x2-x1)*(xg-x2)+(y2-y1)*(yg-y2) > 0;
        d_min = (xg-x2).^2+(yg-y2).^2;
        d(ind) = d_min(ind);
        
        val = zeros(size(d), 'uint8');
        val(d<r^2) = round(h.*sqrt(1-d(d<r^2)./r^2));
        im(y_min:y_max,x_min:x_max) = max(im(y_min:y_max,x_min:x_max), val);
    end
end

