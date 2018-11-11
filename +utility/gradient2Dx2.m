%GRADIENT2DX2 Returns casted to int16 doubled gradient of an image

% Copyright (c) 2011-2014 ETH Zurich, 2015 FiberApp Contributors. All rights reserved.
% Use of this source code is governed by a BSD-style license that can be found in the LICENSE file.

function [gx, gy] = gradient2Dx2(im)
gx = zeros(size(im), 'int16');
gy = zeros(size(im), 'int16');

gx(:,1) = 2*(im(:,2) - im(:,1));
gx(:,end) = 2*(im(:,end) - im(:,end-1));
gx(:,2:end-1) = im(:,3:end) - im(:,1:end-2);

gy(1,:) = 2*(im(2,:) - im(1,:));
gy(end,:) = 2*(im(end,:) - im(end-1,:));
gy(2:end-1,:) = im(3:end,:) - im(1:end-2,:);
