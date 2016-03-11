function [x_p, y_p] = searchPath(im, fibInt, x_0, y_0, x_end, y_end)

% Terminate, if the start point is the same as the end point
if (x_0 == x_end && y_0 == y_end)
    x_p = x_0;
    y_p = y_0;
    return
end

maxn = 65535; % maximum number of nodes

[imY, imX] = size(im);
isOpen = false(imY, imX); % open nodes
isClosed = false(imY, imX); % closed nodes

ID = 0; % number of nodes
pID = zeros(1, maxn, 'uint16'); % parent ID

n = 0; % number of elements in the heap
heap = zeros(1, maxn, 'uint16'); % heap of nodes' IDs

X = zeros(1, maxn, 'uint16'); % nodes' x coordinates
Y = zeros(1, maxn, 'uint16'); % nodes' y coordinates

G = zeros(1, maxn, 'double'); % nodes' path costs
H = zeros(1, maxn, 'double'); % nodes' heuristic costs
F = zeros(1, maxn, 'double'); % nodes' total costs

% Add the starting point to the heap
ID = ID + 1;
X(ID) = x_0;
Y(ID) = y_0;
n = n + 1;
heap(n) = ID;
isOpen(y_0, x_0) = true;

while ID < 10000 && n ~= 0 % until there are nodes in the open list
    % Get ID of the first element from the heap
    id = heap(1);
    
    % Move the last element to the top and sort the heap (sink the first element)
    heap(1) = heap(n);
    heap(n) = 0;
    n = n - 1;
    
    v = 1; % start from the beginning of the heap
    while n >= 2*v
        u = v; % save the previous position
        if n == 2*v
            % One child
            if F(heap(v)) > F(heap(2*u))
                v = 2*u;
            end
        else
            % Two children
            if F(heap(v)) > F(heap(2*u))
                v = 2*u;
            end
            if F(heap(v)) > F(heap(2*u+1))
                v = 2*u+1;
            end
        end
        
        if v ~= u
            temp = heap(v);
            heap(v) = heap(u);
            heap(u) = temp;
        else
            break % exit the sorting loop
        end
    end
    
    % Coordinates of the taken node
    cX = X(id);
    cY = Y(id);
    
    % Close the taken node
    isClosed(cY, cX) = true;
    isOpen(cY, cX) = false;
    
    % Neighbour nodes
    x_n = double(cX) + [-1 -1 -1  0 0  1 1 1];
    y_n = double(cY) + [-1  0  1 -1 1 -1 0 1];
    
    % Check if we've found the destination
    if any(x_n == x_end & y_n == y_end)
        % Track the path coordinates using pID and use maxn as a counter
        x_p = zeros(1, maxn); % path's x coordinates
        y_p = zeros(1, maxn); % path's y coordinates
        x_p(maxn) = x_end;
        y_p(maxn) = y_end;
        while id ~= 0
            maxn = maxn - 1;
            x_p(maxn) = X(id);
            y_p(maxn) = Y(id);
            id = pID(id); % step back
        end
        % Remove remaining zeros
        x_p = x_p(x_p ~= 0);
        y_p = y_p(y_p ~= 0);
        return
    end
    
    % Analyse neighbour nodes
    for k = 1:length(x_n)
        x = x_n(k);
        y = y_n(k);
        
        if x == 0 || x == imX+1 || y == 0 || y == imY+1 || isClosed(y, x)
            continue
        end
        
        if isOpen(y, x)
            % Calculate a new G cost
            if double(im(y, x)) > fibInt
                val = 0;
            else
                val = 10*(1 - double(im(y, x))/fibInt);
            end
            if mod(cX+cY, 2) == mod(x+y, 2)
                tempG = G(id) + sqrt(2)*val; % diagonal move
            else
                tempG = G(id) + val; % horisontal/vertical move
            end
            
            openID = heap(1:n);
            nodeID = heap(X(openID) == x & Y(openID) == y);
            if tempG < G(nodeID)
                pID(nodeID) = id;
                G(nodeID) = tempG;
                F(nodeID) = G(nodeID) + H(nodeID);
                
                % Sort the heap
                v = find(nodeID == openID, 1, 'first'); % start position
                while v ~= 1
                    u = v; % save the previous position
                    if F(heap(v)) < F(heap(floor(u/2)))
                        v = floor(u/2);
                        
                        temp = heap(v);
                        heap(v) = heap(u);
                        heap(u) = temp;
                    else
                        break % exit the sorting loop
                    end
                end
            end
        else
            % Add node to the open list
            isOpen(y, x) = true;
            
            ID = ID + 1;
            pID(ID) = id;
            
            n = n + 1;
            heap(n) = ID;
            
            X(ID) = x;
            Y(ID) = y;
            
            % Calculate costs
            if double(im(y, x)) > fibInt
                val = 0;
            else
                val = 10*(1 - double(im(y, x))/fibInt);
            end
            if mod(cX+cY, 2) == mod(x+y, 2)
                G(ID) = G(id) + sqrt(2)*val; % diagonal move
            else
                G(ID) = G(id) + val; % horisontal/vertical move
            end
            H(ID) = abs(x-x_end) + abs(y-y_end);
            F(ID) = G(ID) + H(ID);
            
            % Sort the heap
            v = n; % start position (from the end)
            while v ~= 1
                u = v; % save the previous position
                if F(heap(v)) < F(heap(floor(u/2)))
                    v = floor(u/2);
                    
                    temp = heap(v);
                    heap(v) = heap(u);
                    heap(u) = temp;
                else
                    break % exit the sorting loop
                end
            end
        end
    end
end

% Couldn't find a path
x_p = [];
y_p = [];

