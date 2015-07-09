% Copyright (c) 2014, ETH Zurich (Switzerland)
% All rights reserved.
function FitFiber(hObject, eventdata)
FA = guidata(hObject);

% Check if there is selected fiber
if FA.sel == 0; return; end

% Check for the presence of gradients
if isempty(FA.gradX) || isempty(FA.gradY)
    [FA.gradX, FA.gradY] = utility.gradient2Dx2(FA.im);
    
    % FiberApp tutorial
    FA.tutorial('start_tracking');
end

% Short names for fiber tracking parameters and data
xy = FA.curIm.xy{FA.sel};
a = FA.alpha;
b = FA.beta;
g = FA.gamma;
k1 = FA.kappa1;
k2 = FA.kappa2;

if ~isempty(FA.curIm.mask{FA.sel})
    m = FA.curIm.mask{FA.sel};
    ma = FA.maskAlpha;
    mb = FA.maskBeta;
end

% Apply fitting algorithm FA.iterations times
for k = 1:FA.iterations
    % Construct a matrix M for the internal energy contribution
    n = length(xy);
    
    if FA.isFiberOpen
        m1 = [3   2 1:n-2         ;
              2     1:n-1         ;
                    1:n           ;
                    2:n   n-1     ;
                    3:n   n-1 n-2];
    else
        m1 = [n-1 n 1:n-2         ;
              n     1:n-1         ;
                    1:n           ;
                    2:n       1   ;
                    3:n   1   2  ];
    end
    
    m2 = cumsum(ones(5,n), 2);
    
    if isempty(FA.curIm.mask{FA.sel})
        col = [b; -a-4*b; 2*a+6*b+g; -a-4*b; b];
        m3 = col(:, ones(n,1));
        
        if FA.isFiberOpen
            m3(:,1:2) = [b       0        ;
                         -2*b    -a-2*b   ;
                         a+2*b+g 2*a+5*b+g;
                         -a-2*b  -a-4*b   ;
                         b       b       ];
                     
            m3(:,end-1:end) = [b         b      ;
                               -a-4*b    -a-2*b ;
                               2*a+5*b+g a+2*b+g;
                               -a-2*b    -2*b   ;
                               0         b     ];
        end
    else
        mp = false(1, n); % points under mask elements
        for l = 1:size(m,2)
            ind = abs(xy(1,:)-m(1,l)) < m(3,l)/2 & ...
                  abs(xy(2,:)-m(2,l)) < m(3,l)/2;
            mp(ind) = true;
        end
        
        A = mp*ma + ~mp*a;
        B = mp*mb + ~mp*b;
        
        if FA.isFiberOpen
            A(1) = 0;
            A(end) = 0;
            B(1) = 0;
            B(end) = 0;
        end
        
        Ap1 = [A(2:end) A(1)];
        Bm1 = [B(end) B(1:n-1)];
        Bp1 = [B(2:end) B(1)];
        
        m3 = [Bm1                ;
              -A-2*(Bm1+B)       ;
              A+Ap1+Bm1+4*B+Bp1+g;
              -Ap1-2*(B+Bp1)     ;
              Bp1               ];
    end
    
    M = sparse(m1, m2, m3, n, n);
    
    % Vector field of external energy
    % (interp2 MATLAB function requests double input, which consume too
    % much memory for big AFM images)
    % gradX and gradY are doubled! (see gradient2Dx2)
    vfx = utility.interp2D(FA.gradX, xy(1,:), xy(2,:), 'cubic')/2;
    vfy = utility.interp2D(FA.gradY, xy(1,:), xy(2,:), 'cubic')/2;
    vf = k1*[vfx; vfy]/FA.fiberIntensity;
    
    % Normalized vectors of fiber ends
    v_start = xy(:,1) - xy(:,2);
    v_start = v_start/sqrt(sum(v_start.^2));
    v_end = xy(:,end) - xy(:,end-1);
    v_end = v_end/sqrt(sum(v_end.^2));
    
    % Image intensities at the ends
    int_start = utility.interp2D(FA.im, xy(1,1), xy(2,1), 'cubic');
    int_end = utility.interp2D(FA.im, xy(1,end), xy(2,end), 'cubic');
    
    % Full external energy
    vf(:,1) = vf(:,1) + k2*v_start*int_start/FA.fiberIntensity;
    vf(:,end) = vf(:,end) + k2*v_end*int_end/FA.fiberIntensity;
    
    % Next position
    xy = utility.distributePoints((g*xy+vf)/M, FA.step);
end

% Save fiber data
FA.curIm.xy{FA.sel} = xy;
FA.curIm.z{FA.sel} = utility.interp2D(FA.im, xy(1,:), xy(2,:), FA.zInterpMethod);

% Save fiber rectangle
FA.fibRect(:,FA.sel) = [min(xy,[],2); max(xy,[],2)];

% Change line position
set(FA.fibLine(FA.sel), 'XData', xy(1,:), 'YData', xy(2,:));

% Trigger updateStatistics and changeSelection in FiberAppData class
FA.sel = FA.sel;

% Data is modified
FA.isDataModified = true;

