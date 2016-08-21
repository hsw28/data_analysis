function h = rgb2hex( rgb )
%RGB2HEX convert rgb colors to hexadecimal
%
%  h=RGB2HEX(rgb) returns the hexadecimal value corresponding to the rgb
%  color. rgb should be a nx3 red-green-blue color array.
%

%  Copyright 2007-2008 Fabian Kloosterman

h = [];

if nargin<1 || isempty(rgb)
  return
end

if ndims(rgb)~=2 || size(rgb,2) ~=3
  error('rgb2hex:invalidSize', 'Not a nx3 rgb color matrix')
end

rgb = round( 255 * rgb );
h = horzcat( dec2hex(rgb(:,1)) , dec2hex(rgb(:,2)) , dec2hex(rgb(:,3)) );
