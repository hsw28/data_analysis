function [new_clust, remainder] = isolate_field_with_phase(clust, varargin)

p = inputParser();
p.addParamValue('field_buffer', 0.2);
% TODO: How to search for STRF's that are far enough from the track bounds?
%  Namely - how do you delete those points, without messing up neighboring
%  fields that _aren't_ too close to the edge?
% p.addParamValue('track_edge_buffer', 0.2); % Do this filtering by hand. 
p.parse(varargin{:});
opt = p.Results;

% Take first field.  Check for outbound first.  Then get inbound
fields = field_bounds(clust,'field_direction','outbound');
field_dir = 'outbound';
if(isempty(fields))
    fields = field_bounds(clust,'field_direction','inbound');
    field_dir = 'inbound';
end
if(isempty(fields))
    % break if there are no outbound or inbound fields
    new_clust = [];
    remainder = [];
    return;
end

if(strcmp(field_dir,'inbound'))
    

this_field = fields(1,:) + opt.field_buffer*[-1,1]