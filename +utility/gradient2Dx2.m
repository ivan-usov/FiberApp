function [gx, gy] = gradient2Dx2(im)
%GRADIENT2Dx2 Summary of this function goes here
%   Returns doubled gradient, to be inside int16 possible values

gx = zeros(size(im), 'int16');
gy = zeros(size(im), 'int16');

gx(:,1) = 2*(im(:,2) - im(:,1));
gx(:,end) = 2*(im(:,end) - im(:,end-1));
gx(:,2:end-1) = im(:,3:end) - im(:,1:end-2);

gy(1,:) = 2*(im(2,:) - im(1,:));
gy(end,:) = 2*(im(end,:) - im(end-1,:));
gy(2:end-1,:) = im(3:end,:) - im(1:end-2,:);
end

