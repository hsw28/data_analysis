function s = makequote( s )
%MAKEQUOTE convert string into quote
%
%  s=MAKEQUOTE(s) convert a string, cell array of strings or structure
%  with strings to quotes.
%

%  Copyright 2007-2008 Fabian Kloosterman

switch class(s)
 case 'cell'
  s = apply2cell( @makequote, {}, s );
 case 'struct'
  s = apply2struct( @makequote, {}, s );
 case 'char'
  if ~isempty(s)
    q = repmat( '''', size(s,1), 1 );
    s = [q s q];
  end
end
