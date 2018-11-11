%OP2D Calculate 2D Order Parameter vs a box size

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function [xdata, ydata] = OP2D(p_all, v_all, xMin, yMin, ...
    gridStep, procStepNum, numCellX, numCellY, isCircleArea)

% Arrange and calculate data in cells
SIZE = [numCellY numCellX];
A = zeros(SIZE);
B = zeros(SIZE);
N = zeros(SIZE, 'uint32');

p_all_x = p_all(1,:);
p_all_y = p_all(2,:);
% First cycle for horizontal slicing
for k = 1:numCellY
    sY = yMin + (k-1)*gridStep;
    ind = find(sY <= p_all_y & p_all_y < sY + gridStep);
    if isempty(ind); continue; end
    
    p_slice_x = p_all_x(ind);
    v_slice = v_all(:,ind);
    
    % Second cycle for vertical slicing
    for l = 1:numCellX
        sX = xMin + (l-1)*gridStep;
        ind = find(sX <= p_slice_x & p_slice_x < sX + gridStep);
        if isempty(ind); continue; end
        
        v_block = v_slice(:,ind);
        A(k,l) = sum(v_block(1,:).^2);
        B(k,l) = sum(prod(v_block));
        N(k,l) = size(v_block,2);
    end
end

xdata = gridStep*(1:procStepNum);
ydata = zeros(1, procStepNum);

% First step (k = 1)
Ah = A;
Av = zeros(SIZE);
a = A;

Bh = B;
Bv = zeros(SIZE);
b = B;

Nh = N;
Nv = zeros(SIZE, 'uint32');
n = N;

% In case of circle area
if isCircleArea
    % These values contain information about corners of the square box
    % 1 - top left corner
    % 2 - top right corner
    % 3 - bottom left corner
    % 4 - bottom right corner
    
    cir1a = zeros(SIZE);
    cir2a = zeros(SIZE);
    cir3a = zeros(SIZE);
    cir4a = zeros(SIZE);
    
    cir1b = zeros(SIZE);
    cir2b = zeros(SIZE);
    cir3b = zeros(SIZE);
    cir4b = zeros(SIZE);
    
    cir1n = zeros(SIZE, 'uint32');
    cir2n = zeros(SIZE, 'uint32');
    cir3n = zeros(SIZE, 'uint32');
    cir4n = zeros(SIZE, 'uint32');
    
    % Construct a matrix for a quarter of the box. Each element of this
    % matrix contain a circle diameter, at which this element doesn't
    % belong to the circle anymore
    [xx, yy] = meshgrid(1:floor(procStepNum/2));
    notInCircle = uint16(ceil(2*(xx+yy-1)+sqrt(4*(2*xx.*yy-xx-yy)+2)));
end

val = sqrt((2*a-double(n)).^2+(2*b).^2)./double(n);
% ----------
% val(n==0) = 0;
% ydata(1) = mean(val(:));
% ----------
ydata(1) = mean(val(n~=0));

% Remaining steps (k = 2:procStepNum)
for k = 2:procStepNum
    Ah = Ah(2:end,1:end-1) + A(k:end,k:end);
    Av = Av(1:end-1,2:end) + A(k-1:end-1,k:end);
    a = a(1:end-1,1:end-1) + Av + Ah;
    
    Bh = Bh(2:end,1:end-1) + B(k:end,k:end);
    Bv = Bv(1:end-1,2:end) + B(k-1:end-1,k:end);
    b = b(1:end-1,1:end-1) + Bv + Bh;
    
    Nh = Nh(2:end,1:end-1) + N(k:end,k:end);
    Nv = Nv(1:end-1,2:end) + N(k-1:end-1,k:end);
    n = n(1:end-1,1:end-1) + Nv + Nh;
    
    % In case of circle area
    if isCircleArea
        cir1a = cir1a(1:end-1, 1:end-1);
        cir2a = cir2a(1:end-1, 2:end);
        cir3a = cir3a(2:end, 1:end-1);
        cir4a = cir4a(2:end, 2:end);
        
        cir1b = cir1b(1:end-1, 1:end-1);
        cir2b = cir2b(1:end-1, 2:end);
        cir3b = cir3b(2:end, 1:end-1);
        cir4b = cir4b(2:end, 2:end);
        
        cir1n = cir1n(1:end-1, 1:end-1);
        cir2n = cir2n(1:end-1, 2:end);
        cir3n = cir3n(2:end, 1:end-1);
        cir4n = cir4n(2:end, 2:end);
        
        [i, j] = find(notInCircle == k);
        for l = 1:length(i)
            ind1i = i(l):i(l)+SIZE(1)-k;
            ind1j = j(l):j(l)+SIZE(2)-k;
            ind2i = 1-i(l)+k:1-i(l)+SIZE(1);
            ind2j = 1-j(l)+k:1-j(l)+SIZE(2);
            
            cir1a = cir1a + A(ind1i, ind1j);
            cir2a = cir2a + A(ind1i, ind2j);
            cir3a = cir3a + A(ind2i, ind1j);
            cir4a = cir4a + A(ind2i, ind2j);
            
            cir1b = cir1b + B(ind1i, ind1j);
            cir2b = cir2b + B(ind1i, ind2j);
            cir3b = cir3b + B(ind2i, ind1j);
            cir4b = cir4b + B(ind2i, ind2j);
            
            cir1n = cir1n + N(ind1i, ind1j);
            cir2n = cir2n + N(ind1i, ind2j);
            cir3n = cir3n + N(ind2i, ind1j);
            cir4n = cir4n + N(ind2i, ind2j);
        end
        
        aa = a - cir1a - cir2a - cir3a - cir4a;
        bb = b - cir1b - cir2b - cir3b - cir4b;
        nn = double(n - cir1n - cir2n - cir3n - cir4n);
    else
        aa = a;
        bb = b;
        nn = double(n);
    end
    
    val = sqrt((2*aa-nn).^2+(2*bb).^2)./nn;
    % ----------
%     val(nn==0) = 0;
%     ydata(k) = mean(val(:));
    % ----------
    ydata(k) = mean(val(nn~=0));
end
