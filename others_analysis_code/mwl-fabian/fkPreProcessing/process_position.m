function process_position(rootdir, step)
%PROCESS_POSITION script to process position data
%
%  PROCESS_POSITION(rootdir,step) processes the position data in
%  rootdir (should be formatted as 'day#'). The script will perform the
%  following operations:
%   0. load raw position data and convert it to diode positions.
%   1. let the user define epochs based on the position data.
%   2. correct diode position data for each epoch (i.e. fill in missing values)
%   3. compute behavioral features for each epoch
%
%  PROCESS_POSITION(rootdir,step) step vector specifies at which
%  of the steps processing will start and stop (default=[0 3]). If
%  step is a scalar it sets the start step and the end step
%  will be 3.
%

%  Copyright 2005-2009 Fabian Kloosterman

%--LOCAL FUNCTION FOR ACTUAL PROCESSING---

startlevel = 0;
endlevel = 3;

    function local_process()
        
        %compute diode position from raw position
        if startlevel<=0

            verbosemsg( 'Computing diode position from raw position' );
            
            posfile = dir( fullfile(rootdir, 'position', 'master*.pos' ) );
            if ~isscalar(posfile)
                error('process_position:invalidFile', 'None or more than 1 .pos file found')
            end
            posfile = fullfile( rootdir, 'position', posfile.name );
            
            status = pos2diode( posfile, fullfile( rootdir, 'position', 'diodes.p') );
          
            LOG.pos2diode = configobj(status);

        end

        %define epochs
        if startlevel<=1 && endlevel>=1
           
            verbosemsg( 'Let user define or update epochs' );
            
            [epoch_names, epochs] = define_epochs( fullfile( rootdir, 'position', 'diodes.p'), fullfile( rootdir, 'epochs', 'epochs.def') );
            
            LOG.define_epochs = configobj( struct( 'names', {epoch_names}, 'epochs', epochs));

            %create epoch directories & symbolic links
            verbosemsg('Creating epochs directory structure...')
            for e=1:numel(epoch_names)
                
                [LOG.(epoch_names{e}).dirs.root, msg, msgid] = mkdir(rootdir, fullfile('epochs', epoch_names{e}));%#ok
                [LOG.(epoch_names{e}).dirs.bounds, msg, msgid] = mkdir(rootdir, fullfile('epochs', epoch_names{e}, 'bounds'));%#ok
                [LOG.(epoch_names{e}).dirs.clusters, msg, msgid] = mkdir(rootdir, fullfile('epochs', epoch_names{e}, 'clusters'));%#ok
                [LOG.(epoch_names{e}).dirs.events, msg, msgid] = mkdir(rootdir, fullfile('epochs', epoch_names{e}, 'events'));%#ok
                [LOG.(epoch_names{e}).dirs.segments, msg, msgid] = mkdir(rootdir, fullfile('epochs', epoch_names{e}, 'segments'));%#ok
                [LOG.(epoch_names{e}).dirs.environment, msg, msgid] = mkdir(rootdir, fullfile('epochs', epoch_names{e}, 'environment'));%#ok
                [LOG.(epoch_names{e}).dirs.position, msg, msgid] = mkdir(rootdir, fullfile('epochs', epoch_names{e}, 'position'));%#ok
                [LOG.(epoch_names{e}).dirs.video, msg, msgid] = mkdir(rootdir, fullfile('epochs', epoch_names{e}, 'video'));%#ok
                [LOG.(epoch_names{e}).dirs.logs, msg, msgid] = mkdir(rootdir, fullfile('epochs', epoch_names{e}, 'logs'));%#ok                
                
                %create relative symbolic links to sources.dat, signals.dat and
                %waveforms directory
                [LOG.(epoch_names{e}).links.sources,result] = system(['ln -s ../../sources.dat ' fullfile(rootdir,'epochs',epoch_names{e},'sources.dat')]); %#ok
                [LOG.(epoch_names{e}).links.signals,result] = system(['ln -s ../../signals.dat ' fullfile(rootdir,'epochs',epoch_names{e},'signals.dat')]); %#ok          
                [LOG.(epoch_names{e}).links.waveforms,result] = system(['ln -s -T ../../waveforms ' fullfile(rootdir,'epochs',epoch_names{e},'waveforms')]); %#ok
                
                %save epoch definition inside epochs directory
                save_epochs( fullfile(rootdir,'epochs',epoch_names{e}), epoch_names(e), epochs(e,:) );

            end
            
        end
        
        %load epochs
        verbosemsg( 'Loading epochs...' );
        [epoch_names, epochs] = load_epochs( rootdir );
        nepochs = numel(epoch_names);
        
        %correct position per epochs
        if startlevel<=2 && endlevel>=2
            
            for e=1:nepochs
                
                verbosemsg( ['Correcting diode positions for epoch ' epoch_names{e}] );
                
                status = correct_position( fullfile( rootdir, 'position', 'diodes.p' ), ...
                    fullfile(rootdir, 'epochs', epoch_names{e}, 'position', 'position.p'), ...
                    'epoch', epochs(e,:) );
            
                LOG.(epoch_names{e}).correct_position = configobj(status);
            end
            
        end
        
        %process epoch behavior
        if startlevel<=3 && endlevel>=3
            
            %find first run epoch
            runidx = find( strncmp( epoch_names, 'run', 3 ), 1, 'first' );
            
            if ~isempty(runidx)
                epochidx = [runidx setdiff(1:nepochs, runidx)];
                savediodeorient=true;
            else
                epochidx = 1:nepochs;
                savediodeorient=true;                
            end
            
            diodeorient = [];
            
            for e=epochidx
                
                verbosemsg( ['Processing behavior for epoch ' epoch_names{e}] );
                
                status = process_behavior( fullfile(rootdir, 'epochs', epoch_names{e}, 'position', 'position.p'), ...
                    fullfile(rootdir, 'epochs', epoch_names{e}, 'position', 'behavior.p'), ...
                    'diodeorientation', diodeorient);
        
                if savediodeorient && isempty(diodeorient)
                    diodeorient = status.diodeorientation;
                end
                
                LOG.(epoch_names{e}).process_behavior = configobj(status);
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
        
        %default step = [0 2]
        if ~exist('step','var')
            startlevel = 0;
            endlevel = 3;
        elseif length(step)==1
            startlevel = step;
            endlevel = 3;
        else
            startlevel = step(1);
            endlevel = step(2);
        end

        LOG_ARGS = {'rootdir', rootdir, 'runlevels', [startlevel endlevel]};
        LOG_DESCRIPTION = 'position processing';
              
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
MODIFICATION_DATE = '$Date: 2009-09-04 12:20:04 -0400 (Fri, 04 Sep 2009) $'; %#ok
REVISION = '$Revision: 2217 $'; %#ok
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
