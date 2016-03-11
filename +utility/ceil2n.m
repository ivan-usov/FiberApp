function out = ceil2n(in)
%CEIL2N Ceil only a small number (<100) up to two significant digits

if in == 0
    out = 0;
    return
end

i = 0;

while(abs(in) < 10)
    i = i-1;
    in = in*10;
end

% while(abs(in) > 100)
%     i = i+1;
%     in = in/10;
% end

out = ceil(in)*10.^i;

