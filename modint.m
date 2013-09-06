function y = modint(x,n)
%function y = modint(x,n)
%
%Finds y=mod(x,n), except in the integer range
%[1...n] instead of [0...n-1], by replacing 0->n

y = mod(x,n);
zinds = find(~y);
y(zinds) = n;