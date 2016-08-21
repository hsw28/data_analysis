function extract_and_process_spikes( destroot, days, srcroot )
%EXTRACT_AND_PROCESS_SPIKES
%
%  EXTRACT_AND_PROCESS_SPIKES(destroot, days) For the specified recording
%  days in the root path: copy raw spike files to raw folder (if
%  necessary) and extract spike files and compute waveform features.
%
%  EXTRACT_AND_PROCESS_SPIKES(destroot, days, srcroot) First copy data
%  files from source path recording day folders to destination path, before
%  further extraction and processing.
%

%  Copyright 2009 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

if isempty( destroot )
    destroot = '.';
end

try
    destroot = fullpath( destroot );
catch ME
    error( 'extract_and_process_spikes:invalidArgument', 'Invalid destination root path' )
end

if isempty(days)
    error( 'extract_and_process_spikes:invalidArgument', 'Invalid days')
end

if ischar( days )
    days = { days };
elseif ~iscellstr( days )
    error( 'extract_and_process_spikes:invalidArgument', 'Invalid days')
end    

if nargin<3 || isempty( srcroot )
    srcroot = [];
elseif ~ischar( srcroot ) || ~exist( srcroot, 'dir')
    error( 'extract_and_process_spikes:invalidArgument', 'Invalid source root path' )
end

%loop through all days
for k=1:numel(days)
    
    destpath = fullfile( destroot, days{k} );
    
    %if day dir exists, ask to skip or delete or continue
    if ~exist( destpath, 'dir' )
        warning('extract_and_process_spikes:invalidDir', ['No destination ' days{k} '. Please extract master file first.'] )
        continue
    end
    
    %if srcroot, copy spike filed from srcroot/day to destdir/day
    if ~isempty(srcroot)
        copyfile( fullfile( srcroot, days{k}, 't*.f*'), destpath );
    end
    
    files = dir( fullfile( destpath, 't*.f*' ) );
    
    if ~isempty( files )
        movefile( fullfile( destpath, 't*.f*' ), fullfile( destpath, 'raw') );
    end
    
    files = dir( fullfile( destpath, 'raw', 't*.f*' ) );
    
    if isempty( files )
        warning( 'extract_and_process_spikes:noFile', ['No spike files found for ' days{k}] )
        continue
    end
    
    %call extract_day
    extract_day( destpath, [0 2 4] );
    
end