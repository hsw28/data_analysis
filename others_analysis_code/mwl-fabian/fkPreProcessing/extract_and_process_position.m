function extract_and_process_position( destroot, days, srcroot )
%EXTRACT_AND_PROCESS_POSITION
%
%  EXTRACT_AND_PROCESS_POSITION(destroot, days) For the specified recording
%  days in the root path: copy raw master file to raw folder (if
%  necessary), extract master file and process position.
%
%  EXTRACT_AND_PROCESS_POSITION(destroot, days, srcroot) First copy data
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
    error( 'extract_and_process_position:invalidArgument', 'Invalid destination root path' )
end

if isempty(days)
    error( 'extract_and_process_position:invalidArgument', 'Invalid days')
end

if ischar( days )
    days = { days };
elseif ~iscellstr( days )
    error( 'extract_and_process_position:invalidArgument', 'Invalid days')
end    

if nargin<3 || isempty( srcroot )
    srcroot = [];
elseif ~ischar( srcroot ) || ~exist( srcroot, 'dir')
    error( 'extract_and_process_position:invalidArgument', 'Invalid source root path' )
end

%loop through all days
for k=1:numel(days)
    
    destpath = fullfile( destroot, days{k} );
    
    %if day dir exists, ask to skip or delete or continue
    if exist( destpath, 'dir' )
        if isempty( srcroot )
            answer = questdlg( ['A directory for ' days{k} ' already exists. Would you like to skip or continue?'], 'Question', 'Continue', 'Skip', 'Continue' );
        else
            answer = questdlg( ['A directory for ' days{k} ' already exists. Would you like to skip or continue?'], 'Question', 'Delete', 'Continue', 'Skip', 'Skip' );
        end
        if strcmp( answer, 'Skip')
            continue
        elseif strcmp( answer, 'Delete')
            rmdir( destpath, 's' );
        else
            %pass
        end
    end
    
    %create day dir
    if ~exist( destpath, 'dir' )
        mkdir( destroot, days{k} );
    end
    if ~exist( fullfile( destpath, 'raw' ), 'dir' )
        mkdir( destpath, 'raw' );
    end
    
    %if srcroot, copy master file from srcroot/day to destdir/day
    if ~isempty(srcroot)
        files = dir( fullfile( srcroot, days{k}, 'master*.f*') );
        if ~isempty(files)
            copyfile( fullfile( srcroot, days{k}, 'master*.f*'), destpath );
        else
            warning('extract_and_process_position:noFile', ['No master file found in source root for ' days{k}] )
            continue
        end
    end
    
    files = dir( fullfile( destpath, 'master*.f*' ) );
    
    if ~isempty( files )
        movefile( fullfile( destpath, 'master*.f*' ), fullfile( destpath, 'raw') );
    end
    
    files = dir( fullfile( destpath, 'raw', 'master*.f*' ) );
    
    if isempty( files )
        warning( 'extract_and_process_position:noFile', ['No master file found for ' days{k}] )
        continue
    end
    
    %call extract_day
    extract_day( destpath, [0 1] );
    
    %process position
    process_position( destpath );
    
end