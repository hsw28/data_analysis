function [data, time] = eeg_clip( time, data, clipsegments, clipvalue )

if nargin<2
    help(mfilename)
    return
end

if nargin<3 || isempty(clipsegments)
    return
end

if nargin<4
    clipvalue = NaN;
end


invalid_idx = seg_select2( clipsegments, time, (1:numel(time))' );
data(invalid_idx,:) = clipvalue;

if nargout>1 && isempty(clipvalue)
    time(invalid_idx{:}) = clipvalue;
end
    


