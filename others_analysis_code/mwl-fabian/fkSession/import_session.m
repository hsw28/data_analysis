function session = import_session(rootdir, varargin)
%IMPORT_SESSION import a session worth of data
%
%  session=IMPORT_SESSION(rootdir) imports data of a recording session
%  stored in rootdir and returns a structure with the following fields:
%   info - session information
%   tetrodes - tetrode information
%   (epochname) - for each epoch a structure with data
%  Each epoch structure has the following fields:
%   info - epoch information
%   environment - track and trajectory information
%   position - behavior data
%   clusters - cluster data and boundaries
%   eeg - eeg inforamtion
%   events - event data
%   segments -  segment data
%
%  session-IMPORT_SESSION(rootdir,param1,val1,...) sets optional
%  parameters. Valid paramaters are:
%   Epochs - name or cell array of names of epoch(s) to be imported
%   Sections - cell array of data to import; valid entries are:
%   'tetrodes', 'environment', 'position', 'clusters', 'eeg', 'events',
%   'segments'
%

%  Copyright 2005-2008 Fabian Kloosterman

VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end

%parse and check arguments
args = struct('Epochs', {{}}, 'Sections', {{}}, 'Interactive', false);
args = parseArgs(varargin, args);

if ~iscell(args.Epochs)
    args.Epochs = {args.Epochs};
end

if isempty(args.Sections)
    args.Sections = {'tetrodes', 'environment', 'position', 'clusters', 'eeg', 'events', 'segments'};
end

if ~iscell(args.Sections)
    args.Sections = {args.Sections};
end

%session info
%--------------------------------------------------------------------------
info.rootdir = fullpath(rootdir);
info.day = str2num( rootdir(end-1:end)); %#ok
info.import_date = datestr(now);

varargincmd = cell2str( varargin );
varargincmd(1)=',';
varargincmd(end)=')';
info.command = ['import_session(''' rootdir ''''  varargincmd];

session.info = info;
%--------------------------------------------------------------------------


%import tetrode information
if ismember('tetrodes', args.Sections) && ...
      (~args.Interactive || strcmp(questdlg('Import tetrode information?','','Yes','No','Yes'),'Yes'))
    
  verbosemsg('Importing tetrode information...')
  %--------------------------------------------------------------------------
  session.tetrodes = import_tetrode_info( rootdir );
  %--------------------------------------------------------------------------
end


%try loading the epochs
%--------------------------------------------------------------------------
if ~exist(fullfile(rootdir, 'epochs', 'epochs.def'), 'file')
  
  verbosemsg('No epoch file found.')
  return
  
else

  [epoch_names epochs] = load_epochs(rootdir);
  nepochs = size(epochs,1);
    
  verbosemsg(['Epoch definitions loaded (n=' num2str(nepochs) ').'])
end
%--------------------------------------------------------------------------


%loop through all epochs
for e = 1:nepochs
  
  %should we import this epoch?
  if (isempty(args.Epochs) || ismember(epoch_names{e}, args.Epochs)) && ...
        (~args.Interactive || strcmp(questdlg(['Import epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))
    
    
    verbosemsg(['Importing epoch: ' epoch_names{e}])
    
    %epoch info
    %----------------------------------------------------------------------
    epoch.info.rootdir = fullfile(info.rootdir, 'epochs', epoch_names{e});
    epoch.info.import_date = info.import_date;
    epoch.info.timestamp = epochs(e,:);
    %----------------------------------------------------------------------
    
    
    %import track
    if ismember('environment', args.Sections) && ...
          (~args.Interactive || strcmp(questdlg(['Import environment for ' ...
                          'epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))
      
      verbosemsg(['Epoch ' epoch_names{e} ' - importing environment...'], VERBOSE_MSG_LEVEL+1)
      %------------------------------------------------------------------
      epoch.environment = import_env( epoch.info.rootdir );
      env_loaded = true;
      %------------------------------------------------------------------
    else
      env_loaded = false;
    end
    
    
    %import position
    if ismember('position', args.Sections) && ...
          (~args.Interactive || strcmp(questdlg(['Import position for epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))
      
      verbosemsg(['Epoch ' epoch_names{e} ' - importing position...'], VERBOSE_MSG_LEVEL+1)
      %------------------------------------------------------------------
      
      if args.Interactive
          posopts = inputdlg( {'tracker rate',
                              'velocity smoothing (sd in seconds)', 
                              'hd change smoothing (sd in seconds)'}, ...
                              'Options for position import', ...
                              1, {'30','0.5','0.1'} );
          if ~isempty(posopts)
              posopts = {'fstracker', str2num(posopts{1}), 'velsmooth', ...
                         str2num(posopts{2}), 'hdchangesmooth', ...
                         str2num(posopts{3}) };
          end
      else
          posopts={};
      end
      
      epoch.position = import_position( epoch.info.rootdir, posopts{:} );
      pos_loaded = true;
      %------------------------------------------------------------------
    else
      pos_loaded = false;
    end
    
    
    %create linearization functions and find epochs for all
    %trajectories (depends on track and position)
    if env_loaded && pos_loaded  && ...
          (~args.Interactive || strcmp(questdlg(['Process trajectories ' ...
                          'for epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))
      
      verbosemsg(['Epoch ' epoch_names{e} ' - processing trajectories...'], VERBOSE_MSG_LEVEL+1)
      %------------------------------------------------------------------
      epoch.environment = process_trajectories( epoch.environment, epoch.position);
      %------------------------------------------------------------------
    end
    
    
    %import clusters
    if ismember('clusters', args.Sections) && ...
          (~args.Interactive || strcmp(questdlg(['Import clusters for ' ...
                          'epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))
      
      %------------------------------------------------------------------
      verbosemsg(['Epoch ' epoch_names{e} ' - importing clusters...'], VERBOSE_MSG_LEVEL+1)
      epoch.clusters = import_clusters( epoch.info.rootdir, session.tetrodes );
      %------------------------------------------------------------------
      
      %import mean waveform and props
      %convert amplitudes to mV (depends on tetrodes)
      %------------------------------------------------------------------
      %verbosemsg('Importing waveforms...')
      if (~args.Interactive || strcmp(questdlg(['Import waveforms for ' ...
                            'epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))
        
        verbosemsg(['Epoch ' epoch_names{e} ' - importing waveforms...'], VERBOSE_MSG_LEVEL+1)        
        epoch.clusters = import_waveform( epoch.info.rootdir, epoch.clusters, session.tetrodes );
        
      end
      
      verbosemsg(['Epoch ' epoch_names{e} ' - compute mean firing rate..'], VERBOSE_MSG_LEVEL+2)
      for c = 1:length(epoch.clusters)
        epoch.clusters(c).rate = epoch.clusters(c).nspikes ./ diff(epoch.info.timestamp);
      end
      %------------------------------------------------------------------
            
      %import cluster position features (depends on position)
      if pos_loaded
        warning('off','MATLAB:interp1:NaNinY')
        verbosemsg(['Epoch ' epoch_names{e} ' - compute behavioral variables...'], VERBOSE_MSG_LEVEL+2)
        %------------------------------------------------------------------
        for c = 1:length(epoch.clusters)
          
          epoch.clusters(c).headpos = interp1(epoch.position.timestamp, epoch.position.headpos, epoch.clusters(c).timestamp, 'nearest');
          epoch.clusters(c).headdir = interp1(epoch.position.timestamp, epoch.position.headdir, epoch.clusters(c).timestamp, 'nearest');
          epoch.clusters(c).velocity = interp1(epoch.position.timestamp, epoch.position.velocity, epoch.clusters(c).timestamp, 'nearest');
          epoch.clusters(c).hdchange = interp1(epoch.position.timestamp, epoch.position.hdchange, epoch.clusters(c).timestamp, 'nearest');          
        
        end
        %------------------------------------------------------------------
        warning('on','MATLAB:interp1:NaNinY')
      end
      
      %import cluster quality measures
      if  numel(epoch.clusters)>0 && (~args.Interactive || strcmp(questdlg(['Import cluster quality measures ' ...
                            'for epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))        
        
        verbosemsg(['Epoch ' epoch_names{e} ' - importing cluster quality measures...'], VERBOSE_MSG_LEVEL+1)      
      
      
        scores = clusterquality( session.info.rootdir, epoch.info, epoch.clusters, session.tetrodes);
        scores = mat2cell(scores(:,3:8), ones(size(scores,1),1), [1 1 4]);
        
        [epoch.clusters.lratio] = deal( scores{:,1} );
        [epoch.clusters.iso_distance] = deal( scores{:,2} );
        [epoch.clusters.subjective_quality] = deal( scores{:,3} );
        
      end
        
      %import bounds
      if  (~args.Interactive || strcmp(questdlg(['Import cluster bounds ' ...
                            'for epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))        
        
        verbosemsg(['Epoch ' epoch_names{e} ' - importing cluster bounds...'], VERBOSE_MSG_LEVEL+1)
        %------------------------------------------------------------------
        for c = length(epoch.clusters):-1:1
          
          bf = mwlopen( fullfile( epoch.info.rootdir, 'bounds', ['D' sprintf('%.2d', session.info.day) '_T' sprintf('%.2d', epoch.clusters(c).tetrode) '.bounds']) );
          epoch.clusters(c).bounds = load(bf, epoch.clusters(c).cluster_id);
          
          if isempty(epoch.clusters(c).bounds)
            verbosemsg(['No bounds found for ' epoch.clusters(c).name ' - cluster unloaded']);
            epoch.clusters(c) = [];
          end
        end
        %------------------------------------------------------------------
      end
      
    end
    
    %import eeg
    if ismember('eeg', args.Sections) && ...
          (~args.Interactive || strcmp(questdlg(['Import eeg for epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))
      verbosemsg(['Epoch ' epoch_names{e} ' - importing eeg...'], VERBOSE_MSG_LEVEL+1)
      %------------------------------------------------------------------
      epoch.eeg = import_eeg( rootdir, epoch_names{e} );
      %------------------------------------------------------------------
    end
    
    
    %import events
    if ismember('events', args.Sections) && ...
          (~args.Interactive || strcmp(questdlg(['Import events for ' ...
                          'epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))
      verbosemsg(['Epoch ' epoch_names{e} ' - importing events...'], VERBOSE_MSG_LEVEL+1)
      %------------------------------------------------------------------
      epoch.events = dir2struct(fullfile(epoch.info.rootdir, 'events'), @load_event);
      %------------------------------------------------------------------
    end
    
    
    %import segments
    if ismember('segments', args.Sections) && ...
          (~args.Interactive || strcmp(questdlg(['Import segments for ' ...
                          'epoch ' epoch_names{e}  '?'],'','Yes','No','Yes'),'Yes'))
      verbosemsg(['Epoch ' epoch_names{e} ' - importing segments...'], VERBOSE_MSG_LEVEL+1)
      %------------------------------------------------------------------
      epoch.segments = dir2struct(fullfile(epoch.info.rootdir, 'segments'), @load_segment);
      %------------------------------------------------------------------
    end
    
    
    %end
    
    %try loading extra data
    %----------------------------------------------------------------------
    %         if exist( fullfile(info.rootdir, 'epochs', epoch_names{e}, 'extra_data.mat') ) && ismember('extra', args.Sections)
    %             extra_data = load( fullfile(info.rootdir, 'epochs', epoch_names{e}, 'extra_data.mat') );
    %             epoch = struct_union( extra_data, epoch );
    %         end
    
    session.(epoch_names{e}) = epoch;
    
  end
end



function result = dir2struct(rootdir, fcn)

result = struct();

filelist = dir(rootdir);

for f = 1:length(filelist)
  
  if filelist(f).isdir==0
    
    [p, fn, e, v] = fileparts( filelist(f).name ); %#ok
    
    %lazy loading
    result.(fn) = @() fcn(rootdir, fn);
    
  elseif filelist(f).isdir && ~ismember(filelist(f).name, {'.', '..'})
    
    result.(filelist(f).name) = dir2struct( fullfile( rootdir, filelist(f).name), fcn );
    
  end
  
end
