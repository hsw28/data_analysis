function [ts, pos] = gh_interp_pos(ts,pos)

dt = mode(diff(ts));
diffs = diff(ts);

new_ts_buffer = [];
new_pos_buffer = [];


for m = 1:numel(diffs)
    if(diffs(m) > dt)
        pre_ind = m;
        post_ind = m+1;
        pre_t = ts(pre_ind);
        post_t = ts(post_ind);
        pre_pos = pos(pre_ind);
        post_pos = pos(post_ind);
        new_times = [pre_t:dt:post_t];
        new_pos = (post_pos - pre_pos) / (post_t - pre_t) * (new_times - pre_t) + pre_pos;
        new_ts_buffer = [new_ts_buffer; new_times' ]; 
        new_pos_buffer = [new_pos_buffer; new_pos' ];
    end
end

ts = [ts; new_ts_buffer];
pos = [pos; new_pos_buffer];

[ts,ind] = sort(ts);
pos = pos(ind);