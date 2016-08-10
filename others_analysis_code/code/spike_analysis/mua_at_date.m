function mua = mua_at_date(dateStr, rat_mua_file_list, varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('keep_groups',[]);
p.addParamValue('trode_groups',[]);
p.addParamValue('arte_correction_factor',[]);
p.addParamValue('ad_trodes',cell(0));
p.addParamValue('arte_trodes',cell(0));
p.addParamValue('sort',true);
p.addParamValue('sort_areas',[]);
p.addParamValue('width_window',[-Inf,Inf]);
p.addParamValue('threshold',[]);
p.addParamValue('segment_style',[]);
p.parse(varargin{:});
opt = p.Results;

if(~isempty(opt.keep_groups))
    if(~isempty(opt.trode_groups))
        tg = opt.trode_groups('date',dateStr,'segment_style',opt.segment_style);
        keep_trodes = cell(0);
        for n = 1:numel(opt.keep_groups)
            this_group = strcmp(opt.keep_groups{n}, cmap(@(x) x.name, tg));
            if(any(this_group))
                keep_trodes = [keep_trodes, tg{this_group}.trodes];
            end
        end
    else
        error('mua_at_data:no_trode_groups','Pass trode_groups if you want to choose keep_groups');
    end
else
    % Take all trodes if keep_groups isn't specified
    display('Try passing in trode_groups and keep_groups');
    flist = rat_mua_file_list({}, dateStr);
    keep_trodes = flist.comp_list;
end
   
%final_flist = rat_mua_file_list( keep_trodes, dateStr );

%mua = immua(final_flist, 'timewin', opt.timewin );

flist_arte = rat_mua_file_list(intersect(keep_trodes, opt.arte_trodes ), dateStr);
keep_arte = cellfun(@(x) any(strcmp(x,opt.arte_trodes)), flist_arte.comp_list);
flist_arte.comp_list = flist_arte.comp_list(keep_arte);
flist_arte.file_list = flist_arte.file_list(keep_arte);

flist_ad = rat_mua_file_list(intersect( keep_trodes, opt.ad_trodes ), dateStr);
keep_ad = cellfun(@(x) any(strcmp(x,opt.ad_trodes)), flist_ad.comp_list);
flist_ad.comp_list = flist_ad.comp_list(keep_ad);
flist_ad.file_list = flist_ad.file_list(keep_ad);

test_flist = rat_mua_file_list({}, dateStr);
assert( (numel(flist_arte.file_list) + numel(flist_ad.file_list)) <= numel(test_flist.file_list) );
 
mua_arte = immua(flist_arte, 'timewin', opt.timewin, 'arte_correction_factor', opt.arte_correction_factor,'t_width',opt.width_window,'threshold',opt.threshold);
mua_ad = immua(flist_ad, 'timewin', opt.timewin, 'arte_correction_factor', 0,'t_width',opt.width_window,'threshold',opt.threshold);

mua = mua_ad;
if(numel(flist_arte.comp_list) > 0)
    mua.clust = [mua.clust, mua_arte.clust];
end
if(~isfield(mua, 'clust'))
    mua.clust = cell(0);
end
mua.nclust = numel(mua.clust);

trode_groups = opt.trode_groups('date',dateStr,'segment_style','areas');

if(opt.sort)
    all_areas = cmap( @(x) x.name, trode_groups);
    opt.sort_areas = [opt.sort_areas, setdiff(all_areas, opt.sort_areas)];
    group_num = zeros(1,numel(mua.clust));
    for n = 1:numel(group_num)
        for g = 1:numel(opt.sort_areas)
            this_trodes = trode_groups{ strcmp(opt.sort_areas{g}, cmap(@(x) x.name, trode_groups))}.trodes;
            if(any(strcmp(mua.clust{n}.comp, this_trodes)))
                group_num(n) = g;
            end
        end
    end
    [~,i] = sort(group_num);
    mua.clust = mua.clust(i);
end
