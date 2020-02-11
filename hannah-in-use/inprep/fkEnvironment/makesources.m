function makesources(target)
%MAKESOURCES build mex files
%
%  MAKESOURCES build all mex files
%
%  MAKESOURCES(targets) build only the target mex files. Targets can be a
%  string or a cell array of strings.
%

% list all available targets here
% targets are assumed to be located in the src directory
%header files should be located in the include subdirectory
available_targets = {};

if nargin<1 || isempty(target)
  target = {'all'};
end

if ~iscell(target)
  target = {target};
end

if ~iscellstr(target)
  error('makesources:invalidArgument', 'Target must be a string or a cell array of strings')
end

target = lower(target);

for i=1:length(available_targets)
  if ismember(available_targets{i}, target) || ismember('all', target)
    eval(['mex -Iinclude src/' available_targets{i} '.c'])
  end
end 