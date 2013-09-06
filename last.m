function y = last(x,N,nocheck,Dim)
%function y = last(x,N,nocheck,Dim)
%takes the last N elements of x, e.g.
%y = x(end-N+1:end);
%
%if optional 'nocheck' flag is set, no
%checking of the input size is performed.
%
%if the optional 'Dim' flag is specified,
%the elements will be taken from that dimension.

if isempty(x)
    y = [];
    return;
end

if (nargin == 3) && nocheck
    y = x(end-N+1:end);
    return;
end

if (nargin == 1)
    N = 1;
end

size_vector = size(x);
if nargin > 3
    if Dim < 1 || Dim > length(size_vector)
        error(['y = last(x,N,nocheck,Dim): Dim (' Dim ') must be between 1 and ndims(x) (' length(size_vector) ')']);
    end
else
    [rows cols] = size(x);
    if (cols == 1) || (rows > cols)
        Dim = 1;
    elseif (rows == 1) || (rows < cols)
        Dim = 2;
    else
        warning('y = last(x,N): Square matrix; assuming dimension 2');
        Dim = 2;
    end
end

if N > size_vector(Dim)
    error(['y = last(x,N,nocheck,Dim): N (' N ') must be less than or equal to the length of X in dimension "Dim" (' size_vector(Dim) ')']);
elseif N < 1
    error(['y = last(x,N,nocheck,Dim): N (' N ') must be >= 1']);
end

switch Dim
    case 1
        y = x(end-N+1:end,:,:,:);
    case 2
        y = x(:,end-N+1:end,:,:);
    case 3
        y = x(:,:,end-N+1:end,:);
    case 4
        y = x(:,:,:,end-N+1:end);
    otherwise
        error(['y = last(x,N,nocheck,Dim): Dim (' Dim ') must be 1, 2, 3, or 4']);
end
