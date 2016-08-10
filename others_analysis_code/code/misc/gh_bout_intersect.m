function out_bouts = gh_bout_intersect(bouts1,bouts2)

if(isempty(bouts2))
    out_bouts = bouts1;
    return;
end

if(isempty(bouts1))
    out_bouts = bouts2;
    return;
end

ts1 = sort([bouts1(:,1);bouts1(:,2)]);
states1 = ones(size(ts1));
n_ts1 = numel(ts1);
zeros_ind = 2:2:n_ts1;
states1(zeros_ind) = 0;

ts2 = sort([bouts2(:,1);bouts2(:,2)]);
states2 = ones(size(ts2));
n_ts2 = numel(ts2);
zeros_ind = 2:2:n_ts2;
states2(zeros_ind) = 0;

ts_all = unique(sort([ts1;ts2]));
state_as_states1 = gh_interp_floor(ts1,states1,ts_all);
state_as_states2 = gh_interp_floor(ts2,states2,ts_all);
sum_state = state_as_states1 + state_as_states2;
out_bouts(:,1) = ts_all(find(sum_state == 2));
out_bouts(:,2) = ts_all(find(sum_state == 2)+1);
