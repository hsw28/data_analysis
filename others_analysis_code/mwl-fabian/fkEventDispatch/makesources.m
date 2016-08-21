function makesources(target)
%MAKESOURCES compile mex source code
%
%  MAKESOURCES make all sources
%
%  MAKESOURCES 'TARGET'  make target only
% 



if nargin<1 || isempty(target)
     target = {'all'};
end

if ~iscell(target)
     target = {target};
end

if ~iscellstr(target)
     error('makesources:invalidArguments', 'Target must be a string or a cell array of strings')
end

target = lower(target);

cfiles = {'process_event_callbacks'};

for i=1:length(cfiles)
     if (ismember(cfiles{i}, target) || ismember('all', target))
         eval(['mex -Iinclude src/' cfiles{i} '.c'])
     end
end 
    
  
