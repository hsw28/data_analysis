function inrange = circ_inrange( theta, range, cyclerange )
%CIRC_INRANGE test wether theta is within range
%
%  inrange=CIRC_INRANGE(theta, range) test if the circular variable theta
%  lies within the arc defined by range. Range is a two elemnt vector
%  specifying the start and end angles of the arc. It is possibl for the
%  start to be larger than the end angle (i.e. [pi 0] defines the range
%  of angles between pi and 2*pi).
%
%  inrange=CIRC_INRANGE(theta, range, cyclerange) sets a custom range of
%  a full cycle (default = [0 2*pi]).
%


%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1 || isempty(theta)
    inrange = [];
    return
end

%if no range is given then all theta are NOT within range
if nargin<2 || isempty(range)
  inrange = zeros(size(theta));
  return
  %if a full range is given then all theta ARE within range
elseif range(1)==range(2)
  inrange = ones(size(theta));
  return
end

%default to [0 2*pi]
if nargin<3 || isempty(cyclerange)
  cyclerange = [0 2*pi];
end

%make sure theta and range are within cyclerange
theta = limit2pi(theta, cyclerange);
range = limit2pi(range, cyclerange);

%test if theta is within range
if range(1)>=range(2)

    inrange = theta>=range(1) | theta<=range(2);

else

    inrange = theta>=range(1) & theta<=range(2);

end
