function makesources(target)
% MAKESOURCES
%
% Usage: makesources(target)
% 
% target: name of the target to be compiled into a mex file


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

cfiles = {'general_radon_c'};

for i=1:length(cfiles)
     if (ismember(cfiles{i}, target) || ismember('all', target))
         eval(['mex -Iinclude src/' cfiles{i} '.c'])
     end
end   
  
