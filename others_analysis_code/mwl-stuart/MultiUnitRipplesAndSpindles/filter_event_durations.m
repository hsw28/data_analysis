function [long, short] = filter_event_durations(dur, per)

if ~isvector(dur)
    error('Specified timestamps must be a vector');
end
if ~isscalar(per)
    error('Burst Length must be a scalar');
end

if per>=.5 || per<0
    error('Percent must be greater than 0 and less than .5');
end

highQuantile = quantile(dur, 1-per);
lowQuantile = quantile(dur, per);


long = find(dur>=highQuantile);
short = find(dur<=lowQuantile);

end