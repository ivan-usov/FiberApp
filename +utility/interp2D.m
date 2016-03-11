function z = interp2D(im, xi, yi, method)
%INTERP2D 2D data interpolation

[nrows, ncols] = size(im);

switch method
    case 'nearest'
        % Check for out of range values of xi and set to 1
        xout = find(xi < .5 | xi > ncols+.5);
        if ~isempty(xout)
            xi(xout) = 1;
        end
        
        % Check for out of range values of yi and set to 1
        yout = find(yi < .5 | yi > nrows+.5);
        if ~isempty(yout)
            yi(yout) = 1;
        end
        
        % Matrix element indexing
        ind = round(yi)+(round(xi)-1)*nrows;
        
        % Now interpolate
        z = double(im(ind));
        
    case 'linear'
        % Check for out of range values of xi and set to 1
        xout = find(xi < 1 | xi > ncols);
        if ~isempty(xout)
            xi(xout) = 1;
        end
        
        % Check for out of range values of yi and set to 1
        yout = find(yi < 1 | yi > nrows);
        if ~isempty(yout)
            yi(yout) = 1;
        end
        
        % Matrix element indexing
        ind = floor(yi)+(floor(xi)-1)*nrows;
        
        % Compute intepolation parameters, check for boundary value
        d = find(xi == ncols);
        xi = xi - floor(xi);
        if ~isempty(d)
            xi(d) = xi(d) + 1;
            ind(d) = ind(d) - nrows;
        end
        
        d = find(yi == nrows);
        yi = yi - floor(yi);
        if ~isempty(d)
            yi(d) = yi(d) + 1;
            ind(d) = ind(d) - 1;
        end
        
        % Now interpolate
        z = (double(im(ind)).*(1-yi) + double(im(ind+1)).*yi).*(1-xi) + ...
            (double(im(ind+nrows)).*(1-yi) + double(im(ind+nrows+1)).*yi).*xi;
        
    case 'cubic'
        % Check for out of range values of xi and set to 1
        xout = find(xi < 2 | xi > ncols-1);
        if ~isempty(xout)
            xi(xout) = 2;
        end
        
        % Check for out of range values of yi and set to 1
        yout = find(yi < 2 | yi > nrows-1);
        if ~isempty(yout)
            yi(yout) = 2;
        end
        
        % Matrix element indexing
        ind = (floor(yi)-1)+(floor(xi)-2)*nrows;
        
        % Compute intepolation parameters, check for boundary value
        d = find(xi == ncols);
        xi = xi - floor(xi);
        if ~isempty(d)
            xi(d) = xi(d) + 1;
            ind(d) = ind(d) - nrows;
        end
        
        d = find(yi == nrows);
        yi = yi - floor(yi);
        if ~isempty(d)
            yi(d) = yi(d) + 1;
            ind(d) = ind(d) - 1;
        end
        
        y0 = ((2-yi).*yi-1).*yi;
        y1 = (3*yi-5).*yi.*yi+2;
        y2 = ((4-3*yi).*yi+1).*yi;
        yi = (yi-1).*yi.*yi;

        z = (double(im(ind)).*y0 + double(im(ind+1)).*y1 + ...
            double(im(ind+2)).*y2 + double(im(ind+3)).*yi) .* ...
            (((2-xi).*xi-1).*xi);
        ind = ind + nrows;
        z = z + (double(im(ind)).*y0 + double(im(ind+1)).*y1 + ...
            double(im(ind+2)).*y2 + double(im(ind+3)).*yi) .* ...
            ((3*xi-5).*xi.*xi+2);
        ind = ind + nrows;
        z = z + (double(im(ind)).*y0 + double(im(ind+1)).*y1 + ...
            double(im(ind+2)).*y2 + double(im(ind+3)).*yi) .* ...
            (((4-3*xi).*xi+1).*xi);
        ind = ind + nrows;
        z  = z + (double(im(ind)).*y0 + double(im(ind+1)).*y1 + ...
            double(im(ind+2)).*y2 + double(im(ind+3)).*yi) .* ...
            ((xi-1).*xi.*xi);
        z = z/4;
end

% Now set out of range values to extval
if ~isempty(xout); z(xout) = 0; end
if ~isempty(yout); z(yout) = 0; end

