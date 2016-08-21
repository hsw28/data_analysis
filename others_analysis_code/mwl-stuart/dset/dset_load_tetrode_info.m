function tetInfo = dset_load_tetrode_info(animal, day, epoch)


metapath = dset_get_tetinfo_file_path(animal);

meta = load(metapath);
meta = meta.tetinfo{day}{epoch};

tetInfo = repmat(struct(), size(meta));
for i = 1:numel(meta)
    
    if isfield(meta{i}, 'hemisphere')
        tetInfo(i).hemisphere = meta{i}.hemisphere;
    else
        tetInfo(i).hemisphere = 'unknown';
    end
    
    if isfield(meta{i}, 'area')
        tetInfo(i).area = meta{i}.area;
    else
        tetInfo(i).area = 'unknown';
    end
    if isfield(meta{i}, 'numcells')
        tetInfo(i).numcells = meta{i}.numcells;
    else
        tetInfo(i).numcells = 0;
    end
    
end