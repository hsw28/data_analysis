function process_events(rootdir)
%PROCESS_EVENTS process event files
%
%  PROCESS_EVENTS(rootdir) cuts the raw event string files according to
%  the defined epochs in epochs.def and save them to the appropriate directories.
%

%  Copyright 2005-2009 Fabian Kloosterman

%--LOCAL FUNCTION FOR ACTUAL PROCESSING---

    function local_process()

        %find the day number in rootdir
        reg_pat = '.*day(?<day>\d+)';
        r = regexp(rootdir, reg_pat, 'names');
        if ~isfield(r, 'day')
            error('process_events:invalidArguments', 'Invalid root directory name')
        else
            day_str = r.day; %#ok
        end        

        %load epochs
        epochfile = fullfile(rootdir, 'epochs', 'epochs.def');
        if ~exist(epochfile, 'file')
                error('process_events:noFile', 'No epochs.def file found.')
        else
            verbosemsg(['Loading epoch definitions from ' epochfile])
            [epoch_names epochs] = load_epochs(rootdir);
            nepochs = size(epochs,1);
        end
  
        %load event strings
        if ~exist(fullfile(rootdir, 'events', ['master' day_str '.es']), 'file')
            error('process_events:noFile', 'No event file found.')
        else
            verbosemsg(['Loading event file master' day_str '.es']);
            f = mwlopen(fullfile(rootdir, 'events', ['master' day_str '.es']));
            events = load(f);
            events.timestamp = double(events.timestamp)./10000;
        end

        %save events for each epoch
        for i=1:nepochs
  
            %find events in epoch
            idx = find( events.timestamp>=epochs(i,1) & events.timestamp<=epochs(i,2) );
  
            LOG.(epoch_names{i}).nevents = numel(idx);
  
            if ~isempty(idx)
    
                verbosemsg(['Saving events for epoch ' epoch_names{i} ' ...'])
    
                %find all unique event strings
                [us, ui, uj] = unique( events.string(idx) ); %#ok
    
                for k=1:numel(us)
      
                    %find all timestamps for event string
                    uidx = uj==k;
                    data = double(events.timestamp(idx(uidx)))./10000;

                    %save it
                    save_event( fullfile( rootdir, 'epochs', epoch_names{i}, 'events' ), us{k}, data );
      
                end
    
            else
                verbosemsg(['No events to save for epoch ' epoch_names{i} '.']);
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
        
        LOG_ARGS = {'rootdir', rootdir};
        LOG_DESCRIPTION = 'process event strings';
        
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
