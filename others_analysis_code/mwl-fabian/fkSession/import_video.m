function v = import_video( rootdir )
%IMPORT_VIDEO import video data
%
%  v=IMPORT_VIDEO(rootdir) import video data from rootdir epoch
%  folder.
%

%  Copyright 2007-2008 Fabian Kloosterman

%VERBOSE
VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end

%initialize structure
v = struct( 'video', struct( 'file', '', 'still', [], 'roi', struct('name',{},'position', {})));

%find all video
allfiles = dir( fullfile( rootdir, 'video' ) );
videofiles = {allfiles(~[allfiles.isdir]).name};
videofiles = regexp( videofiles, '(?<name>.*)\.(avi|still\.png|roi)$', 'names' );
videofiles = cat(1, videofiles{:} );

if isempty(videofiles)
    return
end

videofiles = unique( {videofiles.name} );

%loop through all video files
for k=1:numel(videofiles)
    
    %video
    filename = fullfile( rootdir, 'video', [videofiles{k} '.avi'] );
    if exist( filename, 'file' )
        v.(videofiles{k}).file = fullpath( filename );
    end
    
    %still image
    filename = fullfile( rootdir, 'video', [videofiles{k} '.still.png'] );
    if exist( filename, 'file' )
        v.(videofiles{k}).still = imread( filename );
        if size( v.(videofiles{k}).still, 3 ) == 3
            v.(videofiles{k}).still = rgb2gray( v.(videofiles{k}).still );
        end
    end
    
    %ROIs
    filename = fullfile( rootdir, 'video', [videofiles{k} '.roi'] );
    if exist( filename, 'file' )
        f_roi = mwlopen( filename );
        roi = load( f_roi );
        roi = struct( 'name', roi.name', 'position', squeeze(mat2cell( roi.position, 1, 4, ones(size(roi.position,3),1))));
        v.(videofiles{k}).roi = roi;
    end    
    
end