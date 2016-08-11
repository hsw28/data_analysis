function c = trode_colors(dat, trode_groups)

if(iscell(dat))
    trode_names = dat;
elseif(isempty(dat))
    trode_names = cell(0);
    for n = 1:numel(trode_groups)
        trode_names = [trode_names, trode_groups{n}.trodes];
    end
elseif(isfield(dat,'clust'))
    trode_names = cellfun(@(x) x.comp, dat.clust,'UniformOutput',false);
elseif(isfield(dat,'chanlabels'))
    if(isempty(dat.chanlabels))
        error('trode_colors:no_chanlabels','cdat had to chanlabels');
    end
    trode_names = dat.chanlabels;
elseif(any( [(isfield(dat,'raw')), (isfield(dat,'theta')) ] ) )
    error('trode_colors:wrong_data','You passed an eeg_r.  Need a regular eeg cdat');
else
    error('trode_colors:wrong_data','First arg should be: sdat,cdat,{names}, or [])');
end

cs = cellfun(@(x) lfun_trode_color(x,trode_groups), trode_names,'UniformOutput',false);

c = cell2mat( reshape(cs,[],1) );

end


function c = lfun_trode_color(target, groups)

matched = false;
for n = 1:numel(groups)
    if(any(strcmp(target, groups{n}.trodes)))
        if(matched)
            warning(['Trode named ', target, ' found in more than one trode-group!']);
        end
        matched = true;
        c = groups{n}.color;
    end
end
if(~matched)
%    warning(['Trode named ', target,' not found in any trode-group.']);
    c = [0.85 0.85 0.85];
end

end