function v=onoff(x, choices)
%ONOFF on/off utility
%
%  s=ONOFF(b) returns 'on' when b is true and 'off' otherwise.
%
%  s=ONOFF(b,choices) where choices is a two element cell array, returns
%  choices{1} if b is true and choices{2} otherwise.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<2 || isempty(choices)
  choices = {'on','off'};
elseif ~iscell(choices) || numel(choices)~=2
  error('onoff:invalidInput', 'Invalid choices')
end

if x
  v = choices{1};
else
  v = choices{2};
end
