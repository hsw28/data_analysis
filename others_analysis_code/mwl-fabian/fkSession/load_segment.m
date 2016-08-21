function segment = load_segment(rootdir, segment_name)
%LOAD_SEGMENT load segment data from mwl-style file
%
%  segment=LOAD_SEGMENT(rootdir,segment_name) load a previously saved
%  segment file with the name segment_name from root_dir. The function
%  returns a structure with 'timestamp' and 'description' fields.
%

%  Copyright 2005-2008 Fabian Kloosterman


if nargin<2
    help(mfilename)
    return
end

sf = mwlopen( fullfile(rootdir, [segment_name '.segment']));
segment.description = sf.header('Segment description');
segment.date = sf.header('Date');

data = load(sf);

segment.timestamp = data.timestamp;