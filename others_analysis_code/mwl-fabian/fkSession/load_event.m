function event = load_event(rootdir, event_name)
%LOAD_EVENT load event vector from mwl-style file
%
%  event=LOAD_EVENT(rootdir,event_name) load a previously saved event
%  file with the name event_name from rootdir. The function returns a
%  structure with 'timestamp' and 'description' fields.
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

ef = mwlopen( fullfile(rootdir, [event_name '.event']));
event.description = ef.header('Event description');
event.date = ef.header('Date');

data = load(ef);

event.timestamp = data.timestamp;