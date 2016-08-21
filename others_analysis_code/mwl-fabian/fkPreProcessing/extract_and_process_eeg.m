function extract_and_process_eeg( destroot, days, srcroot )
%EXTRACT_AND_PROCESS_EEG
%
%  EXTRACT_AND_PROCESS_EEG(destroot, days) For the specified recording
%  days in the root path: copy raw eeg files to raw folder (if
%  necessary), extract eeg files and process eeg.
%
%  EXTRACT_AND_PROCESS_EEG(destroot, days, srcroot) First copy data
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
    error( 'extract_and_process_eeg:invalidArgument', 'Invalid destination root path' )
end

if isempty(days)
    error( 'extract_and_process_eeg:invalidArgument', 'Invalid days')
end

if ischar( days )
    days = { days };
elseif ~iscellstr( days )
    error( 'extract_and_process_eeg:invalidArgument', 'Invalid days')
end    

if nargin<3 || isempty( srcroot )
    srcroot = [];
elseif ~ischar( srcroot ) || ~exist( srcroot, 'dir')
    error( 'extract_and_process_eeg:invalidArgument', 'Invalid source root path' )
end

%loop through all days
for k=1:numel(days)
    
    destpath = fullfile( destroot, days{k} );
    
    %if day dir exists, ask to skip or delete or continue
    if ~exist( destpath, 'dir' )
        warning('extract_and_process_eeg:invalidDir', ['No destination ' days{k} '. Please extract master file first.'] )
        continue
    end
    
    %if srcroot, copy master file from srcroot/day to destdir/day
    if ~isempty(srcroot)
        copyfile( fullfile( srcroot, days{k}, 'eeg*.f*'), destpath );
    end
    
    files = dir( fullfile( destpath, 'eeg*.f*' ) );
    
    if ~isempty( files )
        movefile( fullfile( destpath, 'eeg*.f*' ), fullfile( destpath, 'raw') );
    end
    
    files = dir( fullfile( destpath, 'raw', 'eeg*.f*' ) );
    
    if isempty( files )
        warning( 'extract_and_process_eeg:noFile', ['No eeg files found for ' days{k}] )
        continue
    end
    
    %call extract_day
    extract_day( destpath, [0 3] );
    
    %process position
    process_eeg( destpath, 600 );
    
end