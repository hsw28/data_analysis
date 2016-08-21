function export_session(session)
%EXPORT_SESSION export session structure
%
%  EXPORT_SESSION(session) exports the events and segemnts for each epoch
%  in the session structure to disk
%
%  See also IMPORT_SESSION
%

%  Copyright 2005-2008 Fabian Kloosterman

epochs = fieldnames(session);

for e=1:length(epochs)
    
  if ~ismember(epochs{e}, {'info', 'tetrodes'})
        
    if isfield(session.(epochs{e}), 'events')
      %export events
      % move events directory to temporary events directory
      [success, message, messageid] = mkdir( session.(epochs{e}).info.rootdir, 'events_old' );%#ok
      [success, message, messageid] = movefile( fullfile(session.(epochs{e}).info.rootdir, 'events', '*'), ...
                                                fullfile(session.(epochs{e}).info.rootdir, 'events_old'));%#ok
                                                                                                          % save events
      struct2dir(session.(epochs{e}).events, fullfile(session.(epochs{e}).info.rootdir, 'events'), fullfile(session.(epochs{e}).info.rootdir, 'events_old'), 'event');
      % delete temporary directory
      rmdir(fullfile(session.(epochs{e}).info.rootdir, 'events_old'), 's');
    end
        
    if isfield(session.(epochs{e}), 'segments')
      %export segments
      % move events directory to temporary events directory
      [success, message, messageid] = mkdir( session.(epochs{e}).info.rootdir, 'segments_old' );%#ok
      [success, message, messageid] = movefile( fullfile(session.(epochs{e}).info.rootdir, 'segments', '*'), ...
                                                fullfile(session.(epochs{e}).info.rootdir, 'segments_old'));%#ok
                                                                                                            % save events
      struct2dir(session.(epochs{e}).segments, fullfile(session.(epochs{e}).info.rootdir, 'segments'), fullfile(session.(epochs{e}).info.rootdir, 'segments_old'), 'segment');
      % delete temporary directory
      rmdir(fullfile(session.(epochs{e}).info.rootdir, 'segments_old'), 's');
    end
        
  end
end


function struct2dir(s, rootdir, olddir, mode)

loadfcn = eval(['@load_' mode]);
savefcn = eval(['@save_' mode]);

fn = fieldnames(s);

for f = 1:length(fn)
    
  if isstruct(s.(fn{f}))
    if all(ismember({'description', 'timestamp'}, fieldnames(s.(fn{f}))))
      %event or segment structure
      if exist( fullfile(olddir, [fn{f} '.event']), 'file' )
        %load the old file
        oldfile = loadfcn( olddir, fn{f} );
        %compare old and new
        if strcmp(oldfile.description, s.(fn{f}).description) && ...
              size(oldfile.timestamp,1)==size(s.(fn{f}).timestamp,1) && ...
              all(oldfile.timestamp==s.(fn{f}).timestamp)
          %move old file back
          [success, message, messageid] = movefile( fullfile( olddir, [fn{f} '.' mode]), ...
                                                    fullfile( rootdir, [fn{f} '.' mode]));%#ok
        else
          %move old file to .backup
          [success, message, messageid] = movefile( fullfile( olddir, [fn{f} '.' mode]), ...
                                                    fullfile( rootdir, [fn{f} '.' mode '.backup']));%#ok
          %save new event
          savefcn( rootdir, fn{f}, s.(fn{f}).timestamp, s.(fn{f}).description);
        end
      else
        %save new event
        savefcn( rootdir, fn{f}, s.(fn{f}).timestamp, s.(fn{f}).description);    
      end
    else
      %make a directory
      [success, message, messageid] = mkdir(rootdir, fn{f});%#ok
      %recurse
      struct2dir(s.(fn{f}), fullfile(rootdir, fn{f}), fullfile(olddir, fn{f}), mode);
    end
  else
    warning('Invalid field in event structure')
  end
end
