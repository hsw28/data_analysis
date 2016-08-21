function T = T2D_shear(theta, T)
%T2D_SHEAR apply shear to transformation matrix
%
%  t=T2D_SHEAR(theta) returns transformation matrix that represents
%  shearing. Theta can be a scalar or a two element vector specifying the
%  shearing angles in the x and y dimensions.
%
%  t=T2D_SHEAR(theta,t) apply shearing to existing transformation matrix.
%


%  Copyright 2005-2008 Fabian Kloosterman

if (nargin<1)
    help T2D_shear
    return
end

if (isempty(theta) || ~isnumeric(theta) || numel(theta)>2)
    error('T2D_shear:invalidTheta', 'Invalid theta argument')
end

if numel(theta)==1
    theta = [theta theta];
end

if (nargin<2 || isempty(T))
    T = eye(3);
elseif (~isnumeric(T) || size(T,1)~=3 || size(T,2)~=3)
    error('T2D_shear:imvalidMatrix', 'Invalid transformation matrix')
end

ST = [1 theta(1) 0; theta(2) 1 0; 0 0 1];

T = ST*T;
