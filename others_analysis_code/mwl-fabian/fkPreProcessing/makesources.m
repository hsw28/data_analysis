function makesources(target)
%MAKESOURCES compile mex files
%
%  MAKESOURCES(target) compile all targets into mex files
% 


if nargin<1 || isempty(target)
     target = {'all'};
end

if ~iscell(target)
     target = {target};
end

if ~iscellstr(target)
     error('Target must be a string or a cell array of strings')
end

target = lower(target);

%example  
%if (ismember('p2mat', target) | ismember('all', target))
%  mex -Iinclude src/p2mat.c src/mwlIOLib.c src/mwlParseFilterParams.c
%end

  
  
