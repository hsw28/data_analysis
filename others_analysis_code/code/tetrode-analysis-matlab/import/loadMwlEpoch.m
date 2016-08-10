function epochMap = loadMwlEpoch( varargin )
% optional arg: 'filename' default: './epoch.epoch'

p = inputParser();
p.addParamValue('filename','./epoch.epoch');
p.parse(varargin{:});

f = fopen(p.Results.filename);

if(f < 0)
    error('loadMwlEpoch:file_open_error','File open error')
end

epochMap = containers.Map;

line = fgetl(f);
% Drop the comments
while( line(1) == '%' )
    line = fgetl(f);
end

while(ischar(line))
    [key,tStart,tStop] = parseGoodLine(line);
    epochMap(key) = [tStart, tStop];
    line = fgetl(f);
end

end

function [key, tStart, tStop] = parseGoodLine( line )

tabInds = find( double(line) == double( sprintf('\t') ) );
key = line( 1:(tabInds(1)-1) );
tStart = str2double( line( (tabInds(1)+1):(tabInds(2)-1) ) );
tStop  = str2double( line( (tabInds(2)+1):end) );

end