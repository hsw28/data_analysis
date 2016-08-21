function process_video(rootdir, level)
%PROCESS_VIDEO script to process video data
%
%  PROCESS_VIDEO(rootdir) This function is used to (1) capture video from a
%  video DVD, (2) map video frames to timestamps and (3) define regions of
%  interest (roi) in the video. The rootdir argument should point to an epoch
%  folder.
%
%  PROCESS_VIDEO(rootdir,levels) selects which operations to perform:
%  1=capture, 2=map, 3=roi.
%

%  Copyright 2007-2009 fabian Kloosterman

%--LOCAL FUNCTION FOR ACTUAL PROCESSING---

    function local_process()

        %create video directory
        if ~exist( fullfile( rootdir, 'video'), 'dir' )
            [ret, msg, msgid] = mkdir(rootdir, 'video');%#ok
        end

        %capture video
        if any(level==1)
        
            ncapture = 0;
            
            while 1

                %ask for video capture options
                answer = inputdlg({'Video name', 'Title', 'Chapters (range)', 'Bit rate'}, 'Select video capture options', 1, {'video','1','[1 1]','500'});
                
                if isempty(answer) || isempty(answer{1})
                    break;
                end
            
                videoname = answer{1};
                
                %check if exists and ask to overwrite if necessary
                if exist( fullfile( rootdir, 'video', [videoname '.avi'] ), 'file' )
                    tmp = questdlg( ['Video with name ' videoname ' already exists. Overwrite?'], 'Warning', 'Yes', 'No', 'No');
                    if strcmp(tmp,'No')
                        continue
                    end
                end
            
                title = str2num( answer{2} ); %#ok
                if isempty(title) || ~isscalar(title) || title<1
                    warndlg('You entered an invalid title number', 'Warning', 'modal');
                    continue
                end

                chapters = str2num( answer{3} ); %#ok
                if isempty(chapters) || (~isscalar(chapters) && ~isequal(size(chapters),[1 2])) || any(chapters<1)
                    warndlg('You entered an invalid chapter range', 'Warning', 'modal');                    
                    continue
                end

                bitrate = str2num( answer{4} ); %#ok
                if isempty(bitrate) || ~isscalar(bitrate) || bitrate<=0
                    warndlg('You entered an invalid bit rate', 'Warning', 'modal');                    
                    continue
                end
            
                verbosemsg(['Capturing video: ' videoname '...']);
            
                %capture_video
                status = capture_video( 'title', title, 'chapters', chapters, 'name', videoname, 'path', fullfile( rootdir, 'video'), 'bitrate', bitrate );
            
                ncapture = ncapture + 1;
                
                LOG.(['capture' num2str(ncapture)]) = configobj(status);
                
            end
        
        end

        
        %find existing videofiles
        allfiles = dir( fullfile( rootdir, 'video' ) );
        videofiles = {allfiles(~[allfiles.isdir]).name};
        videofiles = regexp( videofiles, '(?<name>.*)\.avi$', 'names' );
        videofile_idx = find( ~cellfun('isempty', videofiles) );
    
    
        if isempty(videofile_idx)
            verbosemsg('No video files found.');
            return
        else
            verbosemsg(['Found ' num2str(numel(videofile_idx)) ' video file' plural(numel(videofile_idx))  '.'])
        end
    
        videofiles = squeeze(struct2cell( cat(2, videofiles{videofile_idx} ) ));
    
        %map frames to timestamps
        if any(level==2)
        
            nmap = 0;
            
            while 1
    
                if numel(videofiles)==1
                    selection = 1;
                else
                    [selection,ok] = listdlg( 'ListString', videofiles, 'SelectionMode', 'single', 'Name', 'Select video file', 'PromptString', 'Please select video file for frame-time mapping');
                    if ~ok, break, end
                end
            
                verbosemsg(['Mapping frames to timestamps for ' videofiles{selection}  '...'])
            
                vidx = index_videofile( fullfile( rootdir, 'video', [videofiles{selection} '.avi'] ) );
    
                %save video index
                if ~isempty(vidx)
                
                    verbosemsg(['Saving frame/timestamp mapping for ' videofiles{selection}  '...'])
                
                    hdr = header('Video file', fullfile( rootdir, 'video', [videofiles{selection} '.avi']), 'Date', datestr(now), 'Video file size', allfiles(videofile_idx(selection)).bytes, 'Video file date', allfiles(videofile_idx(selection)).date);
                    flds = mwlfield( {'frame', 'time'}, {'long', 'double'}, 1);
            
                    mwlcreate( fullfile(rootdir,'video',[videofiles{selection} '.map']), ...
                        'fixedrecord', 'Fields', flds, 'Data', { vidx(:,1), vidx(:,2) }, ...
                        'Mode', 'overwrite', 'Header', hdr,  'FileFormat', 'ascii');
            
                else
                
                    verbosemsg(['Skipping frame/timestamp mapping for ' videofiles{selection}  '...'])
                
                end
            
                nmap = nmap + 1;
                
                LOG.(['map' num2str(nmap)]) = configobj( struct('name', videofiles{selection}, 'nindex', size(vidx,1) ) );
                
                if numel(videofiles)==1
                    break
                end
                
            end
        
        end
    
        %select regions of interest
        if any(level==3)
       
            nroi = 0;
            
            while 1

                if numel(videofiles)==1
                    selection = 1;
                else
                    [selection,ok] = listdlg( 'ListString', videofiles, 'SelectionMode', 'single', 'Name', 'Select video file', 'PromptString', 'Please select video file for frame-time mapping');
                    if ~ok, break, end
                end

            
                %check if still image exists
                if ~exist( fullfile( rootdir, 'video', [videofiles{selection} '.still.png'] ), 'file' )
                    verbosemsg(['No still image for ' videofiles{selection}],0);
                    continue
                end
            
                img = imread( fullfile( rootdir, 'video', [videofiles{selection} '.still.png'] ) );
            
                %check if a .roi file exists
                if exist( fullfile( rootdir, 'video', [videofiles{selection} '.roi'] ), 'file' )
                    f_roi = mwlopen( fullfile( rootdir, 'video', [videofiles{selection} '.roi'] ) );
                    roi = load( f_roi );
                    roi = struct( 'name', roi.name', 'position', squeeze(mat2cell( roi.position, 1, 4, ones(size(roi.position,3),1))));
                else
                    roi = struct('name',{},'position',{});
                end
            
                verbosemsg(['Defining ROIs for ' videofiles{selection}  '...'])
            
                roi = define_roi('image', img, 'regions', roi);
            
                %save ROIs
                verbosemsg(['Saving ROIs for ' videofiles{selection}  '...'])
            
                hdr = header('Video file', fullfile( rootdir, 'video', [videofiles{selection} '.avi']), 'Date', datestr(now), 'Video file size', ...
                    allfiles(videofile_idx(selection)).bytes, 'Video file date', allfiles(videofile_idx(selection)).date);
                
                flds = mwlfield( {'name', 'position'}, {'string', 'double'}, {20, [1 4]});
            
                mwlcreate( fullfile(rootdir,'video',[videofiles{selection} '.roi']), ...
                    'fixedrecord', 'Fields', flds, 'Data', { {roi.name}, cat(3,roi.position) }, ...
                    'Mode', 'overwrite', 'Header', hdr,  'FileFormat', 'ascii');
            
                nroi = nroi + 1;
                
                LOG.(['roi' num2str(nroi)]) = configobj( struct('name', videofiles{selection}, 'nroi', numel(roi) ) );
                
                if numel(videofiles)==1
                    break
                end
                
            end
        
        end
    end

%--LOCAL FUNCTION FOR ARGUMENT CHECKING---

    function local_check_args()

        %check root directory
        if ~exist('rootdir', 'var')
          rootdir = pwd;
        elseif ~ischar(rootdir) || ~exist(rootdir,'dir')
            error('process_eeg:invalidArgument', 'Invalid root directory')
        else
            rootdir = fullpath( rootdir );
        end
        
        if ~exist('level','var') || isempty(level)
            level = [1 2 3];
        elseif ~isnumeric(level) || any(level<1 | level>3)
            error('process_video:invalidArgument', 'Invalid levels')
        end
        
        LOG_ARGS = {'rootdir', rootdir, 'level', level};
        LOG_DESCRIPTION = 'process video';
        
    end

%---END OF LOCAL FUNCTIONS---

%-------------------------------------------------------------------

%---START OF DIAGNOSTICS/VERBOSE/ARGUMENT CHECKING LOGIC---

local_check_args();        

%---VERBOSE---
VERBOSE_MSG_ID = mfilename; %#ok
VERBOSE_MSG_LEVEL = evalin('caller', 'get_verbose_msg_level();'); %#ok
%---VERBOSE---

%---M-FILE DEVELOPMENT STATUS---
MODIFICATION_DATE = '$Date: 2008-12-05 11:33:49 -0500 (Fri, 05 Dec 2008) $'; %#ok
REVISION = '$Revision: 1937 $'; %#ok
MFILE_DEV_STATUS = regexp( [MODIFICATION_DATE REVISION], ['\$Date: (?<modification_date>.*) \$\$Revision: (?<revision>[0-9]+) \$'], 'names'); %#ok
%---M-FILE DEVELOPMENT STATUS---

%---DIAGNOSTICS---
LOGFILE = diagnostics( fullfile(rootdir, 'logs', [mfilename '.log']) );
if ~exist('LOG_ARGS','var')
    LOG_ARGS = {};
end
if ~exist('LOG_DESCRIPTION','var')
    LOG_DESCRIPTION='none';
end
LOG = new_diagnostics_log( LOG_DESCRIPTION, LOG_ARGS{:} );
%---DIAGNOSTICS---

errobj = [];

try

    local_process();
    
    %---DIAGNOSTICS---
    LOG.status = 'complete';
    LOGFILE = addlog( LOGFILE, LOG );
    %---DIAGNOSTICS---
    
catch
   
    %get error
    errobj = lasterror;
  
    %---DIAGNOSTICS---
    LOG.status = 'fail';
    LOG.ERROR = configobj(errobj);
    LOGFILE = addlog( LOGFILE, setcomment(LOG, 'ABORTED', 'inline') );    
    %---DIAGNOSTICS---
  
end

%---DIAGNOSTICS---
write(LOGFILE);
%---DIAGNOSTICS---

if ~isempty(errobj)
    rethrow(errobj);
end

end
