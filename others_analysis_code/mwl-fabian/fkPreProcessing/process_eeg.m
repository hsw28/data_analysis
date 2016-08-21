function process_eeg2(rootdir, Fs_new)
%PROCESS_EEG debuffer and downsample eeg files per epoch
%
%  PROCESS_EEG(rootdir,Fs_new) for each epoch and each eeg file,
%  resample the eeg data by an integer factor such that the final sampling
%  frequency is Fs_new. If the old sampling frequency is not a multiple
%  of Fs_new, then the new sampling frequency will be Fs_old / floor(
%  Fs_old/Fs_new). The resampled data is saved to a new (debuffered) file.
%

%  Copyright 2005-2006 Fabian Kloosterman


%--LOCAL FUNCTION FOR ACTUAL PROCESSING---

    function local_process()

    %load epochs
    verbosemsg('Loading epoch definitions...')
    [epoch_names, epochs] = load_epochs(rootdir);
    nepochs = size(epochs,1);

    %find eeg files
    eeg_pat = 'eeg(?<filenum>\d*)_(?<day>\d+)\.eeg'; %example: eeg_01.eeg or eeg3_07.eeg
    files =  dir(fullfile(rootdir, 'eeg', '*.eeg'));
    r = regexp({files.name}, eeg_pat, 'names');
    matches = find( ~cellfun('isempty', r) );

    %loop through eeg files
    for i=matches

        verbosemsg(['Processing ' files(i).name '...'])
  
        logeeg = ['eeg' r{i}.filenum '_' r{i}.day];
  
        %for each epoch...
        for j=1:nepochs
    
            verbosemsg(['Processing epoch ' epoch_names{j} '...'])
            verbosemsg(['Time range = ' num2str(epochs(j,1)) ' - ' num2str(epochs(j,2))]);

            %create eeg directory
            [ret, msg, msgid] = mkdir(rootdir, fullfile('epochs', epoch_names{j}, ...
                                                    'eeg')); %#ok
            if ret==0
                error('process_eeg:fileError', 'Cannot create directory')
            end
                                                
            status = debuffer_eeg_file( fullfile(rootdir, 'eeg', files(i).name), ...
                fullfile(rootdir, 'epochs', epoch_names{j}, 'eeg', files(i).name), ...
                'epoch', epochs(j,:), 'fs', Fs_new );
            
            LOG.(logeeg).(epoch_names{j}) = configobj(status);
            
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

        %default new sampling frequency
        if ~exist('Fs_new','var') || isempty(Fs_new)
            Fs_new = 1500;
        elseif ~isnumeric(Fs_new) || ~isscalar(Fs_new) || Fs_new<=0
            error('process_eeg:invalidArgument', 'Invalid new sampling rate')
        end
    
        LOG_ARGS = {'rootdir', rootdir, 'fs_new', Fs_new};
        LOG_DESCRIPTION = 'resample and debuffer eeg';
        
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
MODIFICATION_DATE = '$Date: 2009-05-01 11:43:37 -0400 (Fri, 01 May 2009) $'; %#ok
REVISION = '$Revision: 2065 $'; %#ok
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

