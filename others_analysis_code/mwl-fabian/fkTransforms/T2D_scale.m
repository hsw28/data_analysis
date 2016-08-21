function T = T2D_scale(scale, T)
%T2D_SCALE apply scaling to transformation matrix
%
%  t=T2D_SCALE(scale) returns a transformation matrix t that represent a
%  scaling by factor scale. Scale can be a scalar (unforma scaling along
%  x and y dimensions) or a two-element vector that specifies the scaling
%  factors for x and y dimensions separately.
%
%  t=T2D_SCALE(scale,t) applies scaling to existing transformation matrix.
%

%  Copyright 2005-2008 Fabian Kloosterman

if (nargin<1)
    help T2D_scale
    return
end

if (isempty(scale) || ~isnumeric(scale) || numel(scale)>2)
    error('T2D_scale:invalidScale', 'Invalid scale argument')
end

if isscalar(scale)
    scale = [scale scale];
end
    

if (nargin<2 || isempty(T))
    T = eye(3);
elseif (~isnumeric(T) || size(T,1)~=3 || size(T,2)~=3)
    error('T2D_scale:invalidMatrix', 'Invalid transformation matrix')
end

ST = [scale(1) 0 0; 0 scale(2) 0; 0 0 1];

T = ST*T;
