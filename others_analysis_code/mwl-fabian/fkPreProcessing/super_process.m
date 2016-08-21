function super_process( rootdir, datadir)
%SUPER_PROCESS convience function for pre processing
%
%  SUPER_PROCESS(datadir) process the raw data files in datadir. The
%  following function are called: extract_day,
%  describe_sources_and_signals, process_position, process_events and
%  process_eeg (with resample frequency = 600Hz).
%
%  SUPER_PROCESS(datadir,destdir) raw data files in datadir are extracted
%  to the destinatio directory.
%

%  Copyright 2009 Fabian Kloosterman

if nargin<1 || isempty(rootdir)
    rootdir = pwd;
elseif ~ischar(rootdir)
    error('super_process:invalidPath', 'Invalid root directory')
end
  
if nargin<2 || isempty(datadir)
  datadir = rootdir;
elseif ~ischar(datadir) || ~exist(datadir,'dir')
    error('super_process:invalidPath', 'Invalid or non-existing data directory')
end

if ~exist( rootdir, 'file' )
    [status, msg, msgid] = mkdir(rootdir);
end

%extract all files
extract_day( datadir, 0:4, rootdir );

%describe sources and signals
describe_sources_and_signals( rootdir );

%process position and define epochs
process_position( rootdir );

%process events
process_events( rootdir );

%process eeg
eeg_fs = 600;
process_eeg( rootdir, eeg_fs );

end