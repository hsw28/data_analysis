function [epochTime] = dset_load_epoch_times(animal, day, epoch, varargin)

posfile = dset_get_pos_file_path(animal, day);
p = load(posfile);
p = p.pos{day}{epoch};

epochTime(1) = p.data(1,1);
epochTime(2) = p.data(end,1);

end