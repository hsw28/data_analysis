function [r_pos_array,gsdat] = decode_pos_with_trode_pos(sdat,pos,trode_groups,varargin)
% DECODE_POS_WITH_TRODE_POS - returns pdf array 
%
% [r_pos_array,gsdat] = decode_pos_with_trode_pos(sdat,pos,trode_groups,varargin)
% Inputs:
% sdat: unit data
% pos: pos_info struct
% trode_groups: return from call to [ratname]_trode_groups
% r_timewin: timewin over which to carry out reconstruction
% f_timewin:
% n_track_seg: num track segs to use if recomputing place fields
% r_tau: reconstruction bin width (sec)
% field_direction: use fields from 'inbound' or 'outbound' runs
% fraction_overlap: reconstruction sliding window, how much to slide over r_tau
%
% Outputs:
% r_pos_array
% gsdat

p = inputParser();
p.addParamValue('r_timewin',[],@isreal);
p.addParamValue('f_timewin',[],@isreal);
p.addParamValue('r_ranges',[]);
p.addParamValue('n_track_seg',50,@isreal);
p.addParamValue('r_tau',0.250,@isreal);
p.addParamValue('field_direction','outbound');
p.addParamValue('fraction_overlap',0);
p.parse(varargin{:});
opt = p.Results;

ngroup = numel(trode_groups);

nclust = numel(sdat.clust);

if(isempty(opt.r_timewin))
    r_bounds = [min(pos.timestamp), max(pos.timestamp)];
else
    r_bounds = opt.r_timewin;
end

toDelete = zeros(1,length(ngroup));
for i = 1:ngroup
    this_ind = [];
    for j = 1:nclust
        if(any(strcmp(sdat.clust{j}.comp, trode_groups{i}.trodes)))
            this_ind = [this_ind,j];
        end
    end

    if numel(this_ind) < 1
        disp(['This group had no cells']);
        doDelete(i) = 1;
        %gsdat{i} = [];
        %r_pos_array(i) = [];  -- This is totally wrong!! array size changeing while indices to delete stay the same
    else 
        gsdat{i} = sdatslice(sdat,'index',this_ind);
        r_pos_array(i) = gh_decode_pos(gsdat{i},pos,'r_timewin',r_bounds,...
            'r_tau',opt.r_tau,'field_direction',opt.field_direction,...
            'fraction_overlap',opt.fraction_overlap,'r_ranges',opt.r_ranges);
    end
end
gsdat(logical(toDelete)) = [];
r_pos_array(logical(toDelete)) = [];
ngroup = length(r_pos_array);

for i = 1:ngroup
%	  r_pos_array(i)
%	  trode_groups{i}
r_pos_array(i).trodes = trode_groups{i}.trodes;
r_pos_array(i).color = trode_groups{i}.color;
end

%comp_img = sum(img,3);
