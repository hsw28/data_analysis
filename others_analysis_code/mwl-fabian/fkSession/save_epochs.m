function save_epochs(save_dir, epoch_names, epochs, varargin)
%SAVE_EPOCHS save epoch definitions
%
%  SAVE_EPOCHS(rootdir,epoch_names,epochs) Saves epoch definitions to a
%  epochs.def file in rootdir/epochs
%
%  epoch_names is a cell array of N strings
%
%  epochs is a Nx2 array of times with column one, row i representing the
%  start time of epoch_name{i} and column two representing the end of the
%  same epoch
%

%  Copyright 2007-2008 Fabian Kloosterman
args.epoch_file = 'none';
args = parseArgs(varargin, args);

if strcmp(args.epoch_file, 'none');
    args.epoch_file = fullfile(save_dir,  'epochs.def');
end


flds = mwlfield({'ep_name', 'ep_start', 'ep_end'}, {'string', 'double', ...
                    'double'}, {10 1 1});
data.ep_name = epoch_names;
data.ep_start = epochs(:,1)';
data.ep_end = epochs(:,2)';


f = mwlcreate(args.epoch_file, 'feature', 'Fields', ...
              flds, 'FileFormat', 'ascii', 'Mode', 'overwrite', 'Data', data); %#ok
disp([args.epoch_file, ' saved!']);
