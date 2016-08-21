function superobj = super(obj, base)
%SUPER super object of object
%
%  superobj=SUPER(obj) returns the super object of an object or [] if
%  none exists. Only works for single inheritance.
%
%  superobj=SUPER(obj,1) returns the super base object of an object. Only
%  works for single inheritance.
%


% super -- Super-object of an object.
%  super(theObject) returns the super-object
%   of theObject, or [] if none exists.

% Copyright (C) 1996 Dr. Charles R. Denham, ZYDECO.
%  All Rights Reserved.
%   Disclosure without written consent from the
%    copyright owner does not constitute publication.

if nargin < 1, help super, return, end

if nargin<2
  base = 0;
end

if base==0
  
  superobj = super_helper( obj );
  
else
  
  while ~isempty(obj)
    superobj = obj;
    obj = super_helper( superobj );
  end

end

if nargout==0
  disp(superobj)
  clear superobj
end


function superobj = super_helper( obj )

s = struct(obj);
fn = fieldnames( s );

if ~isempty(fn)
  superobj = s.(fn{length(fn)});
  if ~isobject(superobj) || ~isa(obj, class(superobj) )
    superobj = [];
  end
else
  superobj = [];
end

