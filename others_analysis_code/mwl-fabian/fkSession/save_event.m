function save_event(rootdir, event_name, events, description)
%SAVE_EVENT save event data to mwl-style file
%
%  SAVE_EVENT(rootdir,event_name,events,description) save a list of event
%  times to a mwl type file. The file will be stored in rootdir with the
%  name event_name (extension is .event). Description is an optional
%  string to give more information about the events.
%
%  See also LOAD_EVENT
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<3
    help(mfilename)
    return
end

if nargin<4 || isempty(description)
    description = ' ';
end

flds = mwlfield({'timestamp'},{'double'}, 1);

hdr = header('Event name', event_name, 'Event description', description, ...
             'Date', datestr(now));

if numel(events)<100 %save as ascii
  f = mwlcreate(fullfile(rootdir, [event_name '.event']), 'feature', ...
                'Fields', flds, 'FileFormat', 'ascii', 'Data', {events}, ...
                'Header', hdr, 'Mode', 'overwrite'); %#ok
else %save as binary
  f = mwlcreate(fullfile(rootdir, [event_name '.event']), 'feature', ...
                'Fields', flds, 'FileFormat', 'binary', 'Data', {events}, ...
                'Header', hdr, 'Mode', 'overwrite'); %#ok
end

