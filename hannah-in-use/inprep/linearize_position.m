function [lin_pos nodes] = linearize_position(xpos, ypos, track_type, interp)
%
%   LINEARIZE_POSITION(xpos, ypos, track_type, interp) returns a vector of 
%   linearized position, created from a timeseries of x and y coordiantes.
%
%   Will also try to interpolate and fill in missing position information
%   when possible
%
%   Supported Track Types:
%       'Linear'    - simple linear track in any orientation
%       'Circular'  - simple cirucular track
%       'Spline'    - a "bendy" linear track
%       'Complex'   - a track with choice poits
%
%   interp (0/1): if set to one then script will interpolate position by
%   replacing NAN's with a linearly interpolated position, this may be
%   replaced later but is not guarenteed.
%
%   If a complex track type is selected then nodes also will be returned.
%   Nodes is the distance in meters from the start of the track where a
%   junction was created between two section of the track that were
%   linearized independently.
%
% requries fkSegments

switch track_type
    case 'Linear'
        lin_pos = linearize_linear_track(xpos, ypos);
        nodes = [min(lin_pos) max(lin_pos)];
    case 'Circular'
        lin_pos = linearize_circular_track(xpos, ypos);
        nodes = [min(lin_pos) max(lin_pos)];
    case 'Spline'
        lin_pos = linearize_complex_track(xpos,ypos);
        nodes = [min(lin_pos) max(lin_pos)];
    case 'Complex'
        [lin_pos nodes] = linearize_complex_track(xpos, ypos);
    otherwise
        disp(['Track type:', track_type, ' not supported'])
        disp('Run help linearize_position for more information');
        lin_pos = [NaN NaN NaN];
    return
end

if ~interp
    return;
end

segs = logical2seg(1:length(lin_pos), isnan(lin_pos));
before_nan = segs(:,1)-1;
after_nan = segs(:,2)+1;
seg_len = after_nan-before_nan;

short_seg_ind = seg_len<1000;
long_seg_ind = seg_len>1000;
figure; plot(lin_pos,'.'); hold on;
%interpolate the short segments
disp('Interpolating position for missing points');
for i=1:length(short_seg_ind)
    if before_nan(i)<1
        before_nan(i) = after_nan(i);
    end
    start_p = lin_pos(before_nan(i));
    if after_nan(i)>numel(lin_pos)
        after_nan(i) = numel(lin_pos);
    end
    end_p = lin_pos(after_nan(i));
    incr = (end_p - start_p)/seg_len(i);
    new_seg = start_p:incr:end_p-incr;
    lin_pos(before_nan(i):before_nan(i)+length(new_seg)-1) = new_seg;
    plot(before_nan(i):before_nan(i)+length(new_seg)-1, new_seg,'r.')
    title('Interpolated Position in Red');
end;
hold off;

    
    