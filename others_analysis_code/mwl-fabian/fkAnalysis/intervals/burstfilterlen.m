function burst = burstfilterlen(burst, len)
%BURSTFILTERLEN remove bursts of particular length
%
%  Syntax
%
%      B = burstfilterlen(A, len)
%
%  Description
%
%    This function will remove all bursts from A that have more than len
%    number of events. If len is a two element vector it specifies the
%    lower and upper boundaries of burst lengths. All bursts outside these
%    boundaries will be removed. The burst vector A, as also returned by
%    burstdetect, contains 0 for non-burst events, and 1,2,3 for the first,
%    middle and last events in a burst. 
%
%  Example
%
%      e = cumsum( rand(100,1) );
%      ib = burstdetect( e );
%      nb = burstfilterlen( ib, [3 7] );
%
%  See also BURSTDETECT, BURSTFILTER
%

% Copyright 2005-2005 Fabian Kloosterman


if nargin<2
    help(mfilename)
    return
end

% check arguments
if ~isnumeric(burst) || ~isnumeric(len)
    error('Invalid arguments.')
end

% find fisrt and last events in bursts
burststart = find(burst==1);
burstend = find(burst==3);

% determine burst lengths
burstlen = burstend-burststart+1;

% find burst to remove
if length(len)==2
    burstremove = find(burstlen<len(1) | burstlen>len(2));
else
    burstremove = find(burstlen>=len);
end

% loop to do actual removal
for i=1:length(burstremove)
    
    burst( burststart(burstremove(i)):burstend(burstremove(i)) ) = 0;
    
end