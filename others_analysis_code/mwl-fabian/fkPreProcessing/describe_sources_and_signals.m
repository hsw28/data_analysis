function [sources, signals] = describe_sources_and_signals( rootdir, varargin )
%DESCRIBE_SOURCES_AND_SIGNALS collect information about all sources and signals
%
%  [sources,signals]=DESCRIBE_SOURCES_AND_SIGNALS(rootdir) this function
%  will search for all signal files in the root directory and present the
%  user with the option to enter/update sources and signals. If no root
%  directory is specified the current directory will be searched. Sources
%  represent physical sensors and signals represent the data collected
%  from a source. Currently, both spike files (*.tt) and eeg files
%  (*.eeg) are recognized. 
%

%  Copyright 2005-2006 Fabian Kloosterman


%--LOCAL FUNCTION FOR ACTUAL PROCESSING---

    function local_process()
        
        %get sources
        if exist( fullfile( rootdir, 'sources.dat' ), 'file' )
            verbosemsg('Reading existing sources.dat...')
  
            fid = mwlopen( fullfile( rootdir, 'sources.dat' ) );
            sources = load( fid );
            
        else
            
            sources = struct( 'id', 1, 'name', 'ground', 'sensor', 'ground', 'description', '');
            
            %ask for template
            answer=questdlg('Select template for source', 'Select template', 'From File', 'EIB-81', 'None', 'None');
            
            switch answer
                case 'From File'
                    %ask for file
                    [sourcesfile, sourcespath] = uigetfile('sources.dat', 'Select sources file', fullfile( rootdir, 'sources.dat') );
                    if ~isequal(sourcesfile,0)
                        %load sources template
                        try
                            fid = mwlopen( fullfile( sourcespath, sourcesfile ) );
                            sources = load( fid );
                        catch
                        end
                    end
                case 'EIB-81'
                    sources = local_sources_EIB81();
                case 'None'
            end
        end

        %let user create/update sources
        sources = define_sources( sources );
        
        %read in signals
        if exist( fullfile( rootdir, 'signals.dat' ), 'file' )
  
            verbosemsg('Reading existing signals.dat...')
  
            fid = mwlopen( fullfile( rootdir, 'signals.dat' ) );
            signals = load( fid );
            
        else
            
            %discover signals automatically
            signals = discover_signals( rootdir );
            
        end
        
        %let user connect signals to sources
        [sources,signals] = connect_sources_and_signals( sources, signals );
        
        %save signals and sources
        verbosemsg('Saving sources and signals...')
        export_sources_and_signals( rootdir, sources, signals);
    
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
        LOG_DESCRIPTION = 'define sources and signals';
        
    end

    function src = local_sources_EIB81()
        
        names = {'T01','T02','T03','T04','T05','T06','EG11','EG12',...
                 'T07','T08','T09','T10','T11','T12','EG21','EG22',...
                 'T13','T14','T15','T16','T17','T18','EG31','EG32'};
             
        src = struct( 'id', 1, 'name', 'ground', 'sensor', 'ground', 'description', '');
        
        for k=1:numel(names)
            src(k+1) = struct('id', k+1, 'name', names{k}, 'sensor', '', 'description', '');
        end
        
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
