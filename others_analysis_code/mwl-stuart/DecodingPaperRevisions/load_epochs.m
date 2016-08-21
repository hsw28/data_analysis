function [epoch_names, epochs]=load_epochs(epoch_dir, varargin)
%LOAD_EPOCHS load epoch definition file
%
%  [epochnames,epochs]=LOAD_EPOCHS(rootdir) Loads the epoch names and
%  epoch times from a epochs.def file in rootdir/epochs
%
%  of if 'epoch_file', file location is specified then the file will be
%  loaded from there
%
%  Copyright 2007-2008 Fabian Kloosterman

args.epoch_file = 'none';
args = parseArgs(varargin, args);

if strcmp(args.epoch_file, 'none')
    file = fullfile(epoch_dir, 'epochs.def');

    if ~exist(file);
        file = fullfile(epoch_dir, 'epochs.def');
    end

else
    file = args.epoch_file;
end

try
  f = mwlopen( file );
  epochs = load(f);
  
  epoch_names = epochs.ep_name;
  epochs = [epochs.ep_start; epochs.ep_end]';
  clear f;
catch
  error('load_epochs:invalidFile', 'Cannot load epochs')
end
