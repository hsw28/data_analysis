function g = group_of_trode(trode_groups,trode,varargin)
% function g = GROUP_OF_TRODES(trode_groups,trode)
% Takes a trode_groups cell array and a trode name
% returns the one trode_group struct containing that trode name
% or [] if no goup is found
% (if multiple trode groups contain, we return the first

p = inputParser();
p.addParamValue('return_val','group');
p.parse(varargin{:});
opt = p.Results;

g = [];

for iG = 1:numel(trode_groups)
    if(any(strcmp(trode, trode_groups{iG}.trodes)))
        if isempty(g)
            g = trode_groups{iG};
            if(strcmp(opt.return_val,'ind'))
                  g = iG;
            end
        else
            error('group_of_trode:too_many_matches',...
                   'group_of_trode found too many matches');
        end
    end
end

if isempty(g)
    %error('group_of_trode:no_matches',...
     %      'group_of_trode didn''t find any matches');
g.name  = 'NONE';
g.trodes = cell(0);
g.color   = [1,0,0];
end
