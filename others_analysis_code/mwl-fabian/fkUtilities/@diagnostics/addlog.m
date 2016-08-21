function L = addlog(L, val)
%ADDLOG add new log to diagnostics file
%
%  d=ADDLOG(d,log) adds new log to diagnostics object (it is not yet
%  written to file!). A log must be a valid configobj instance.
%

%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<2
  return
end

if ~isa( val, 'configobj' )
  error('Diagnostics:addlog:invalidLog', 'Invalid diagnostics log section' )
end

%save date the log was added
val.log_date = datestr(now);
val = setcomment( val, 'log_date', 'added automagically', 'inline' );

%add log
L.configobj.(['log' num2str(L.nlog+1)]) = val;
L.nlog = L.nlog+1;
