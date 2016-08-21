function data = T2D_transform(data, T)
%T2D_TRANSFORM apply transformation to 2D coordinates
%
%  xy=T2D_TRANSFORM(xy,t) applies transform in matrix t to the 2d
%  coordinates xy.
%

%  Copyright 2005-2008 Fabian Kloosterman


if nargin<1
    help(mfilename)
    return
end


if nargin<2 || isempty(T)
    return
end

if (~isnumeric(T) || size(T,1)~=3 || size(T,2)~=3)
    error('T2D_transform:invalidMatrix', 'Invalid transformation matrix')
end

data = [data ones( size(data,1), 1 )] * T';

data = data(:,[1 2]);
