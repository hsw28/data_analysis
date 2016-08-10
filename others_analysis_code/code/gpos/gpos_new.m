function gpos = gpos_new(varargin)
% GPOS_NEW creates a gpos struct with gpos_opt options see gpos
% Either (a) pass args for set_raw and render,
% Passing in a gpos will copy old gpos and change only specified params
% Passing gpos_set_raw_opt will take all opt values, manual settings
% override
% Passing gpos_render_opt behaves the same way

%%%%%%%%%%%%%% Do Input Parser Stuff %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
p = inputParser();
p.addParamValue('gpos',[],@(x) isfield(x,'is_gpos'));
% p.addParamValue('gpos_opt',[],@(x) isfield(x,'is_gpos_opt'));

% params for manual gpos_set_raw
for m = 1:numel(gpos_set_raw_opt_fields)
    % fyi: gpos_set_raw_opt_fields is a function that returns field names
    % for gpos_set_raw_opt struct
    p.addParamValue(gpos_set_raw_opt_fields{m},[]);
end

% params for gpos_set_raw_opt
p.addParamValue('gpos_set_raw_opt',[],@(x) isfield(x,'is_gpos_set_raw_opt'));

% params for render manual default values
for m = 1:numel(gpos_set_render_opt_fields)
    p.addParamValue(gpos_set_render_opt_fields,[]);
end

% params for render opt default values
p.addParamValue('gpos_render_opt',[],@(x) isfield(x,'is_gpos_render_opt'));

p.parse(varargin);
opt = p.Results;


%%%%%%%%%%%% Start Combining gpos fields and gpos_set_raw_opt fields %%%%%%%%%%%%

gpos = opt.gpos;  % use all values specified in input gpos
if(~isempty(opt.gpos_set_raw_opt))
    gpos.gpos_set_raw_opt = opt.gpos_opt; % replace gpos_set_raw_opt if we got a new one
    gpos.raw_needs_refresh = true;
end

% change individual fields in gpos_set_raw_opt
for m = 1:numel(gpos_set_raw_opt_fields)
    this_field = gpos_set_raw_opt_fields{m};
    if(~isempty(getfield(opt,this_field)))
        setfield(gpos.gpos_set_raw_opt,this_field,...
            getfield(opt,this_field));
        gpos.raw_needs_refresh = true;
    end
end


%%%%%%%%%%% Recalculate Raw Datas %%%%%%%%%%%%%%%%%%%%%%%%
if(isfield(gpos,'gpos_needs_refresh'))
    if(gpos.gpos_needs_refresh)
        this_opt = getfield(opt,{1},'field',gpos_set_raw_opt_fields);
        gpos = gpos_set_raw(gpos,'gpos_raw_opt',gpos.gpos_raw_opt,this_opt);
        gpos.render = []; % new raw data necesitates re-rendering
    end
end

