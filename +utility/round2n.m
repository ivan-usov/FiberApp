function out = round2n(in)
%ROUND2N Round a number up to two significant digits

if in == 0
    out = 0;
    return
end

i = 0;

while(abs(in) < 10)
    i = i-1;
    in = in*10;
end

while(abs(in) > 100)
    i = i+1;
    in = in/10;
end

out = round(in)*10.^i;

