function new_cdat = gh_clean_phase(old_cdat)

if(any(abs(old_cdat.data) > pi))
    error('Looks like gh_clean_phase got something other than phase');
end

new_cdat = old_cdat;

n_chan = size(old_cdat.data,2);
ts = conttimestamp(old_cdat);

%pre_nan = find(isnan(old_cdat.data))

for n = 1:n_chan
    %n
    this_series = old_cdat.data(:,n) + pi; % to make the mod's easier.  We'll put it back in the end
    old_numel = numel(this_series);
    diff1 = diff(this_series);
    bad_diff = find(and( diff1 < 0 , diff1 > (-2*pi + 0.3))) + 1; % the 0.3 should work for mid-to-high sampling rates?
    % this gives indices for bad points and local mins.  
    
    local_mins = find( [0; and( this_series(1:end-2) > this_series(2:end-1), this_series(2:end-1) < this_series(3:end)); 0] );
    trouble_ind = setdiff(bad_diff,local_mins);
    
    ok_ind = setdiff(1:old_numel,trouble_ind);
    tmp_ts = ts(ok_ind);
    tmp_dat = unwrap(this_series(ok_ind));
    %nan_in_unwrapped = find(isnan(tmp_dat))
    interp_dat = interp1(tmp_ts,tmp_dat,ts,'linear','extrap');
    %nan_in_interp = find(isnan(interp_dat))
    new_dat = mod(interp_dat,2*pi)-pi;
    new_cdat.data(:,n) = new_dat;
end
        
%post_nan = find(isnan(new_cdat.data))