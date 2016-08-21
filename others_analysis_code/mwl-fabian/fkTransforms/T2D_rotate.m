function T = T2D_rotate(phi, T, origin)
%T2D_ROTATE apply rotation to transformation matrix
%
%  t=T2D_ROTATE(phi) returns the transformation matrix t that represents
%  a rotation by phi radians.
%
%  t=T2D_ROTATE(phi,t) applies the rotation to existing transformation
%  matrix.
%
%  t=T2D_ROTATION(phi,t,origin) applies rotation around the specified
%  origin (default = [0 0])
%

%  Copyright 2005-2008 Fabian Kloosterman

if (nargin<1)
  help T2D_rotate
  return
end

if (isempty(phi) || ~isscalar(phi) )
  error('T2D_rotate:invalidAngle', 'Invalid phi argument')
end

if (nargin<2 || isempty(T))
  T = eye(3);
elseif (~isnumeric(T) || size(T,1)~=3 || size(T,2)~=3)
  error('T2D_rotate:invalidMatrix','Invalid transformation matrix')
end

if nargin<3 || isempty(origin)
  origin = [0 0];
end

T = T2D_translate(-origin, T);
RT = [cos(phi) -sin(phi) 0; sin(phi) cos(phi) 0; 0 0 1];
T = RT*T;
T = T2D_translate(origin, T);

