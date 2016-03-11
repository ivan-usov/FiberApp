classdef FiberAppData < handle
    %FIBERAPPDATA FiberApp core class
    
    properties % Basic data
        spApi               % scroll panel API
        spAxes              % scroll panel axes
        
        panels                      % references to all panels
        openPanels                  % references to the open panels
        defaultPanels = {'ImageParameters', ...   % initially open panels
            'FiberTrackingParameters', ...
            'FiberDataInformation'};
        
        isTutorial = false  % show tutorial messages
        tutorialShowed = {};    % list of showed tutorial messages
    end
    
    properties % Image properties
        name = char.empty;
        path = char.empty;
        im
        sizeX
        sizeY
        sizeX_nm
        sizeY_nm
        scaleXY
        scaleZ
        viewMinZ
        viewMaxZ
        viewMinZ_nm
        viewMaxZ_nm
        colorMap = utility.getColorMap('gray');
    end
    
    properties % Fiber tracking parameters
        gradX
        gradY
        
        isFiberOpen = true;
        alpha = 0;
        beta = 500;
        gamma = 20;
        kappa1 = 20;
        kappa2 = 10;
        fiberIntensity = 100;
        step = 3;
        step_nm
        zInterpMethod = 'cubic';
        iterations = 100;
        autoFit = true;
        aStar = false;
    end
    
    properties % Mask properties
        maskSize = 10;
        maskAlpha = 0;
        maskBeta = 0;
        setMask = false;
        maskLine; % Pointers to mask elements
    end
    
    properties % Fiber view properties
        fiberColor = [0 0 1];
        selFiberColor = [1 0 0];
        maskLineColor = [0 1 0];
        scaleBarColor = [0.5 0 1];
        
        fiberStyle = 1; % 1 - 'line'; 2 - 'point'
        selFiberStyle = 1;
        
        fiberWidth = 1;
        selFiberWidth = 1;
        maskLineWidth = 1;
        scaleBarWidth = 3;
    end
    
    properties
        dataName = char.empty;
        dataPath = char.empty;
        isDataModified = false;
        imageData = ImageData;      % Stored image data
        curIm = ImageData.empty;    % Reference to the current image data
        sel = 0;                    % Number of the selected fiber
        fibLine;    % Pointers to contour lines
        fibRect;    % Boxes in which the contours are incorporated
    end
    
    methods
        function set.openPanels(this, val)
            this.openPanels = val;
            this.updatePanelPosition;
        end
        
        % -----------------------------------------------------------------
        % Update GUI values (Image parameters) ----------------------------
        % -----------------------------------------------------------------
        function set.name(this, val)
            this.name = val;
            set(findobj('Tag', 'e_name'), 'String', val, ...
                'TooltipString', val);
        end
        
        function set.sizeX(this, val)
            this.sizeX = val;
            set(findobj('Tag', 'e_sizeX'), 'String', val);
        end
        
        function set.sizeY(this, val)
            this.sizeY = val;
            set(findobj('Tag', 'e_sizeY'), 'String', val);
        end
        
        function set.sizeX_nm(this, val)
            this.sizeX_nm = val;
            set(findobj('Tag', 'e_sizeX_nm'), 'String', val);
        end
        
        function set.sizeY_nm(this, val)
            this.sizeY_nm = val;
            set(findobj('Tag', 'e_sizeY_nm'), 'String', val);
        end
        
        function set.viewMaxZ(this, val)
            this.viewMaxZ = val;
            set(findobj('Tag', 'e_viewMaxZ'), 'String', val);
        end
        
        function set.viewMinZ(this, val)
            this.viewMinZ = val;
            set(findobj('Tag', 'e_viewMinZ'), 'String', val);
        end
        
        function set.viewMaxZ_nm(this, val)
            this.viewMaxZ_nm = val;
            set(findobj('Tag', 'e_viewMaxZ_nm'), 'String', val);
        end
        
        function set.viewMinZ_nm(this, val)
            this.viewMinZ_nm = val;
            set(findobj('Tag', 'e_viewMinZ_nm'), 'String', val);
        end
        
        % -----------------------------------------------------------------
        % Update GUI values (Fiber tracking parameters) -------------------
        % -----------------------------------------------------------------
        function set.alpha(this, val)
            this.alpha = val;
            set(findobj('Tag', 'e_alpha'), 'String', val);
        end
        
        function set.beta(this, val)
            this.beta = val;
            set(findobj('Tag', 'e_beta'), 'String', val);
        end
        
        function set.gamma(this, val)
            this.gamma = val;
            set(findobj('Tag', 'e_gamma'), 'String', val);
        end
        
        function set.kappa1(this, val)
            this.kappa1 = val;
            set(findobj('Tag', 'e_kappa1'), 'String', val);
        end
        
        function set.kappa2(this, val)
            this.kappa2 = val;
            set(findobj('Tag', 'e_kappa2'), 'String', val);
        end
        
        function set.fiberIntensity(this, val)
            this.fiberIntensity = val;
            set(findobj('Tag', 'e_fiberIntensity'), 'String', val);
        end
        
        function set.step(this, val)
            this.step = val;
            set(findobj('Tag', 'e_step'), 'String', val);
        end
        
        function set.step_nm(this, val)
            this.step_nm = val;
            set(findobj('Tag', 'e_step_nm'), 'String', val);
        end
        
        function set.iterations(this, val)
            this.iterations = val;
            set(findobj('Tag', 'e_iterations'), 'String', val);
        end
        
        % -----------------------------------------------------------------
        % Update statistics -----------------------------------------------
        % -----------------------------------------------------------------
        function set.dataName(this, val)
            this.dataName = val;
            set(findobj('Tag', 'e_dataName'), 'String', val, ...
                'TooltipString', val);
            set(findobj('Type', 'uimenu', 'Label', 'Save Data As'), ...
                'Enable', 'on');
        end
        
        function set.isDataModified(this, val)
            this.isDataModified = val;
            if val; str = 'on';
            else str = 'off';
            end
            menuItems = findobj('Type', 'uimenu', ...
                'Label', 'Save Data');
            toolbarItems = findobj('Type', 'uipushtool', ...
                'TooltipString', 'Save Data');
            set([menuItems; toolbarItems], 'Enable', str)
            set(findobj('String', '*'), 'Visible', str);
        end
        
        function set.curIm(this, val)
            % Activate menu items and hide introduction string with the first image opening
            if isempty(this.curIm)
                this.enableItems();
                set(findobj('Type', 'uicontrol', 'Tag', 'intro_string'), 'Visible', 'off');
            end
            
            this.curIm = val;
            this.updateStatistics();
        end
        
        function set.sel(this, val)
            this.changeSelection(val);
            this.sel = val;
            this.updateStatistics();
        end
    end
    
    methods
        tutorial(this, varargin);
        enableItems(this);
        changeSelection(this, varargin);
        updateStatistics(this);
        checkAccordance(this);
        updateImage(this, varargin);
        pan_zoom(this, varargin);
        len = getScaleBarLineLength(this);
        [xdata, ydata] = getPoint(this);
        [xdata, ydata] = getFiber(this);
        [xdata, ydata, size] = getMask(this);
        renderFibers(this, varargin);
    end
end

