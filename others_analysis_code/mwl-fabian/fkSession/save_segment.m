function save_segment(rootdir, segment_name, segments, description)
%SAVE_SEGMENT save segment data to mwl-style file
%
%  SAVE_SEGMENT(rootdir,segment_name,segments,description) save a list of
%  segments to a mwl type file. The file will be stored in rootdir with
%  the name segment_name (extension is .segment). Description is an
%  optional string to give more information about the segments.
%
%  See also LOAD_SEGMENT
%

%  Copyright 2005-2008 Fabian Kloosterman

if nargin<3
    help(mfilename)
    return
end

if nargin<4 || isempty(description)
    description = '';
end

flds = {'timestamp', 'double', 8, 2};

hdr = header('Segment name', segment_name, 'Segment description', description, ...
             'Date', datestr(now));


f = mwlcreate(fullfile(rootdir, [segment_name '.segment']), 'feature', 'Fields', flds, 'FileType', 'ascii', 'Data', {segments}, 'Header', hdr);%#ok


