function f = inrange( x, r, option )
%INRANGE test whether numbers are within range
%
%  b=INRANGE(x,range) returns true for values in x that are within the
%  specified range. The range is a two element vector specifying the
%  lower and upper bounds of the range. if range(2)<range(1) then the
%  valid range is inverted. If range is scalar then the range will be set
%  to [range Inf].
%
%  b=INRANGE(x,range,'imag') returns true if both magnitude and angle are
%  within range.
%
%  Example
%    b=inrange(10, [5 9]); %returns 0
%    b=inrange(10, [9 5]); %returns 1
%    b=inrange(1+8i, [0 pi]); %returns 1
%
%  See also CIRC_INRANGE
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<2
  error('inrange:invalidArguments', 'Need two input arguments')
end

if ~isnumeric(x)
  error('inrange:invalidArguments', 'Invalid data')
end

if isnumeric(r) && isscalar(r)
  r = [r Inf];
elseif ~isnumeric(r) || numel(r)~=2
  error('inrange:invalidArguments', 'Invalid range')
end
 
if nargin<3 || isempty(option)
  option='real';
end


switch option
  
 case 'real'
  if r(2)>=r(1)
    f = x>=r(1) & x<=r(2);
  else
    f = x>=r(1) | x<=r(2);
  end
   
 case 'imag'
  
  if abs(r(2))>=abs(r(1))
    f = abs(x)>=abs(r(1)) & abs(x)<=abs(r(2)) & circ_inrange( angle(x), ...
                                                      angle(r) );  
  else
    f = ( abs(x)>=abs(r(1)) | abs(x)<=abs(r(2)) ) & circ_inrange( angle(x), ...
                                                      angle(r) );     
  end
 
 otherwise
  
  error('inrange:invalidArguments', 'Invalid option')

end
