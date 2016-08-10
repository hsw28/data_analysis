function place_cells = place_cells_clean_from_sdat(sdat,varargin)

p = inputParser();
p.addParamValue('json_file',[]);
p.parse(varargin{:});
opt = p.Results;

% Collect all featurenames
feat_names_set = cellfun(  @(x) x.featurenames, sdat.clust, 'UniformOutput', false );
feat_names = unique( cat(2, feat_names_set{:}) );
empty_mirror = cellfun( @(x) {} , feat_names, 'UniformOutput', false );

the_args = reshape( [feat_names; empty_mirror], 1, []);

place_cells = struct( 'trode_name', {}, the_args{:} );
for c = 1:numel(sdat.clust)
    
    place_cells(c).trode_name = sdat.clust{c}.comp;
    
    for f = 1:numel(feat_names)
        if(~strcmp('blen', feat_names(f)))
            this_feat_col = strcmp( sdat.clust{c}.featurenames, feat_names(f));
            if(any(this_feat_col))
             d = sdat.clust{c}.data(:, this_feat_col );
             place_cells(c).(feat_names{f}) = reshape(d,1,[]);
            end
      end
    end
end

if(~isempty(opt.json_file))
    f = fopen(opt.json_file,'w');
    if(f < 1)
        disp( ['Could not open for writing : ', opt.json_file] );
    else
        s = savejson(opt.json_file, place_cells);
        rv = fwrite(f, s);
    end
end
        