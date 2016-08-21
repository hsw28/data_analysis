function T = T2D_translate(offset, T)
%T2D_TRANSLATE apply translation to transformation matrix
%
%  t=T2D_TRANSLATE(offset) returns tranaformation matrix representing a
%  translation. Offset can be a scalar or two element vector specifying
%  the translation in x and y dimensions.
%
%  t=T2D_TRANSLATION(offset,t) applies translation to exisiting
%  transformation matrix.
%

%  Copyright 2005-2008 Fabian Kloosterman

if (nargin<1)
    help T2D_translate
    return
end

if (isempty(offset) || ~isnumeric(offset) || numel(offset)>2 )
    error('T2D_translate:invalidOffset', 'Invalid offset argument')
end

if isscalar(offset)
    offset = [offset offset];
end

if (nargin<2 || isempty(T))
    T = eye(3);
elseif (~isnumeric(T) || size(T,1)~=3 || size(T,2)~=3)
    error('T2D_translate:invalidMatrix', 'Invalid transformation matrix')
end

TT = [1 0 offset(1); 0 1 offset(2); 0 0 1];

T = TT*T;
