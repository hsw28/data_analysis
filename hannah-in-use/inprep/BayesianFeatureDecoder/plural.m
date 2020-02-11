function v=plural(x,p)
%PLURAL make plural
%
%  s=PLURAL(n) returns 's' if n is not equal to one, returns ''
%  otherwise.
%
%  s=PLURAL(n,p) returns p if n is not equal to one, returns ''
%  otherwise.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<2 || ~ischar(p)
  p = 's';
end

if isequal(x,1)
  v='';
else
  v=p;
end
