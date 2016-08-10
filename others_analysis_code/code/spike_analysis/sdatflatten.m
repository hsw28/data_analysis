function new_sdat = sdatflatten(old_sdat, varargin)

p = inputParser;
p.addRequired('old_sdat',@isstruct);
p.addParamValue('index',[],@(x)and(min(x) >= 1, max(x) <= numel(old_sdat.clust)));
p.addParamValue('names',cell(0),@iscell);
p.addParamValue('inplace',true,@islogical);
p.parse(old_sdat,varargin{:});
opt = p.Results;

if(opt.inplace)
    % keep the old entire sdat for re-inserting the merged part
    old_copy = old_sdat;
end

if(and (not(isempty(opt.index)), not(isempty(opt.names))))
    error('sdatflatten:too_many_specifiers','Please specify index or names, not both');
end
if(not(isempty(opt.index)))
    old_sdat = sdatslice(old_sdat,'index',opt.index);
end
if(not(isempty(opt.names)))
    old_sdat = sdatslice(old_sdat,'names',opt.names);
end
if(and(isempty(opt.index), isempty(opt.names)))
    % do nothing.  old_sdat to be merged is the whole sdat
end

new_sdat = old_sdat; % copy over old_sdat first (get sdat metadata)
new_sdat.nclust = 1; % this will be true soon, after flattening
new_epochs = cell(0);

nclust = numel(old_sdat.clust);

big_data_array = [];

for i = 1:numel(old_sdat.clust);
    big_data_array = [big_data_array;old_sdat.clust{i}.data];
    new_epochs = [new_epochs, old_sdat.clust{i}.epochs];
end

new_epochs = unique(new_epochs);

big_data_array2 = zeros(size(big_data_array));

t_param_ind = find(strcmp('time',old_sdat.clust{1}.featurenames));

[y,i] = sort(big_data_array(:,t_param_ind));
first_col_index = i;

for j = 1:numel(first_col_index)  % sort bid_data_array by spike_times
    %j
    %first_col_index(j)
    %big_data_array2(first_col_index(j),2)
    %big_data_array(j,:)
    big_data_array2(first_col_index(j),:) = big_data_array(j,:);
end

new_sdat.clust = cell(0);
new_sdat.clust{1} = old_sdat.clust{1}; % copy over all old info - most non-derived stuff is still good
new_sdat.clust{1}.data = big_data_array2;
new_sdat.clust{1}.featurenames = old_sdat.clust{1}.featurenames;
new_sdat.clust{1}.stimes = big_data_array2(:,find(strcmp('time',new_sdat.clust{1}.featurenames)));
new_sdat.clust{1}.nspike = size(big_data_array2,1);
new_sdat.clust{1}.epochs = new_epochs;

clust_name = [''];
for i = 1:nclust
    clust_name = [clust_name,old_sdat.clust{i}.name];
end
new_sdat.clust{1}.name = clust_name;

return_sdat = old_copy;
return_sdat.clust = cell(0);
cursor_point = 1;
ins_point = opt.index(1);
if(opt.inplace)
    for n = 1:numel(old_copy.clust)
        if(and(ins_point == cursor_point, not(isempty(new_sdat.clust))))
            return_sdat.clust{cursor_point} = new_sdat.clust{1};
            cursor_point = cursor_point + 1;
        end
        if(not(any(n == opt.index)))
            return_sdat.clust{cursor_point} = old_copy.clust{n};
            cursor_point = cursor_point + 1;
        end
    end
    new_sdat = return_sdat;
end
%         
% if(opt.inplace)
%     insert_index = opt.index(1);
%     opt.index = opt.index(2:numel(opt.index));
%     keep_index = [];
%     for i = 1:numel(old_copy.clust)
%         if((not(max(i == opt.index))))
%             keep_index = [keep_index,i];
%         end
%     end
%     old_copy.clust{insert_index} = new_sdat.clust{1};
%     old_copy = sdatslice(old_copy,'index',keep_index);
%     new_sdat = old_copy;
% end
