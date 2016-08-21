function c = dset_get_ref_channel(animal, day, epoch)
    
metapath = dset_get_tetinfo_file_path(animal);
    
metaAll = load(metapath);
meta = metaAll.tetinfo{day}{epoch};


for i = 1:numel(meta)
   m = meta{i};
   
   if isfield(m, 'area') && strcmp(m.area,'Reference')
       c = i;
       return;
   end
    
end

    
    
