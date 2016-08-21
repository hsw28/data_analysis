function h=polarcursor(varargin)
%POLARCURSOR creates a polar cursor
%
%  h=POLARCURSOR creates a new polar cursor in the current axes. A handle
%  to the cursor is returned,
%
%  h=POLARCURSOR(lim) creates a polar cursor with the specified angular
%  limits. Lim should be a two element vector.
%
%  h=POLARCURSOR(hax,...) creates a polar cursor in the axes with handle
%  hax.
%
%  h=POLARCURSOR(...,param1,val1,...) sets polar cursor properties
%  through parameter/value pairs. Execute set(h) to see a list of valid
%  properties that can be set.
%

%  Copyright 2008-2008 Fabian Kloosterman

%get axes handle from arguments, if any
[hAx,args,nargs] = axescheck(varargin{:}); %#ok

if nargs==0
  anglelim = [0 0.5*pi];
elseif nargs==1 && isnumeric(args{1}) && isequal(size(args{1}),[1 2])
  anglelim = mod( mod( args{1}, 2*pi) + 2*pi, 2*pi );
else
  error('polarcursor:invalidArgument', 'Invalid angular range or incorrect number of arguments');
end
  
hAx = newpolarplot( hAx );

h=fkGraphics.polarcursor(args{:},'Parent', hAx, 'AngleLim', anglelim);