function new_sdat = sdatslice(old_sdat,varargin)
% new_sdat = SDATSLICE(old_sdat ['index',[], 'names',{'',''}, 'timewin',[],
%   'epochs', {'',''}]
% new_sdat is the intersection of subsets taken from all given parameters
% if you want to union things, call this function over the params
% individually, and sdatcombine (NOT IMPLEMENTED YET) the results 

% needs testing, especially in the following areas:
% repeated indices, searching for names that match multiple clusters

p = inputParser;
p.addRequired('old_sdat',@isstruct);
p.addParamValue('sdatname',[old_sdat.name,'_slice'],@ischar);
p.addParamValue('index',[],@(x)(and(min(x)>0,max(x)<=numel(old_sdat.clust))));
p.addParamValue('names',cell(0));
p.addParamValue('trodes',cell(0));
p.addParamValue('timewin',[]); % this can be a timewin, or an nx2 bouts list
p.addParamValue('epochs',cell(0),@(x)not(isempty(x)));
p.addParamValue('exclude',false,@islogical); % this option tosses the indexed clusts instead of keeping them

p.parse(old_sdat,varargin{:});
opt = p.Results;

if(not(isempty(opt.index)))
    % copy old_sdat into new_sdat, w/out clusts
    if(opt.exclude)
        opt.index = setdiff(1:numel(old_sdat.clust),opt.index);
    end
    new_sdat = struct();
    new_sdat.name = opt.sdatname;
    new_sdat.clust = cell(0);
    new_sdat.userdata = old_sdat.userdata;

    for i = 1:numel(opt.index)
        new_sdat.clust{i} = old_sdat.clust{opt.index(i)};
    end
    %new_sdat.nclust = numel(new_sdat.clust);
    old_sdat = new_sdat; % we want to carry the results into the next operation
end

if(not(isempty(opt.names)))
    % filter by cell name
    n_name = numel(opt.names);
    old_names = cell(0);
    clust_index = [];
    for n = 1:numel(old_sdat.clust)
        old_names{n} = old_sdat.clust{n}.name;
    end
    for i = 1:n_name
        this_index = find(strcmp(opt.names{i},old_names));
        if(not(isempty(this_index)))
            clust_index = [clust_index, this_index];
        else
            error(['Failed to find clust by name: ', opt.names{i}]);
        end
    end
    new_sdat = sdatslice(old_sdat,'index',clust_index);
    old_sdat = new_sdat;
end

if( ~isempty(opt.trodes) )
    keep_bool = cellfun( @(x) any(strcmp(x.comp, opt.trodes)), old_sdat.clust);
    old_sdat.clust = old_sdat.clust(keep_bool);
    new_sdat = old_sdat;
end

if (not(isempty(opt.timewin)))
    % cut spiketimes and data down by timewin
    new_sdat = old_sdat;
    
    for i = 1:numel(new_sdat.clust)
        
        [~,logical_ok_times] = gh_times_in_timewins(new_sdat.clust{i}.stimes,p.Results.timewin);
        
        logical_ok_times = logical(logical_ok_times);
        size(logical_ok_times);
        
        size(new_sdat.clust{i}.stimes);
        new_sdat.clust{i}.stimes = new_sdat.clust{i}.stimes(logical_ok_times);
        size(new_sdat.clust{i}.stimes);
        
        if(isfield(new_sdat.clust{i},'data'));
            new_sdat.clust{i}.data = new_sdat.clust{i}.data(logical_ok_times,:);
        end
        
        new_sdat.clust{i}.nspike = sum(logical_ok_times);
    end
    old_sdat = new_sdat;
    %size(new_sdat.clust{i}.data)
    %size(new_sdat.clust{i}.stimes)
end

if (not(isempty(opt.epochs)))
    clust_index = [];
    for i = 1:numel(old_sdat.clust)
        clust_epochs = old_sdat.clust{i}.epochs;
        ok_matrix = zeros(numel(opt.epochs),numel(clust_epochs));
        for j = 1:numel(opt.epochs)
            ok_matrix(1,:) = strcmp(opt.epochs{j},clust_epochs);
        end
        if(sum(sum(ok_matrix))>0)
            clust_index = [clust_index,i];
        end
    end
    old_sdat.clust;
    clust_index;
    new_sdat = sdatslice(old_sdat,'sdatname',opt.sdatname,'index',clust_index);
end
return