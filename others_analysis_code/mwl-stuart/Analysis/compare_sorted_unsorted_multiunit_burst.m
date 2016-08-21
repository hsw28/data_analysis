%%  Midazolam MULTI Tracker


clear mu;

exp = e;

mu.mid.unsorted = exp.midazolam.multiunit.times;
mu.mid.sorted = singleToMulti(exp.midazolam.clusters);

mu.con.sorted = singleToMulti(exp.control.clusters);
mu.con.unsorted = exp.control.multiunit.times;

mu.mid.lims(1) = min([mu.mid.unsorted(1), mu.mid.sorted(1)]);
mu.mid.lims(2) = max([mu.mid.unsorted(end), mu.mid.sorted(end)]);

mu.con.lims(1) = min([mu.con.unsorted(1), mu.con.sorted(1)]);
mu.con.lims(2) = max([mu.con.unsorted(end), mu.con.sorted(end)]);

mu.mid.bins =  mu.mid.lims(1):.01:mu.mid.lims(2);
mu.con.bins =  mu.con.lims(1):.01:mu.con.lims(2);

mu.mid.unsorted_bin = histc(mu.mid.unsorted, mu.mid.bins);
mu.mid.sorted_bin = histc(mu.mid.sorted, mu.mid.bins);

mu.con.unsorted_bin = histc(mu.con.unsorted, mu.con.bins);
mu.con.sorted_bin = histc(mu.con.sorted, mu.con.bins);
%%
figure;
subplot(211);
plot(mu.mid.bins, mu.mid.unsorted_bin); hold on; plot(mu.mid.bins,mu.mid.sorted_bin,'r');

subplot(212);
plot(mu.con.bins, mu.con.unsorted_bin); hold on; plot(mu.con.bins, mu.con.sorted_bin,'r');
%%
mu.mid.ratio = mu.mid.sorted_bin./mu.mid.unsorted_bin;
mu.con.ratio = mu.con.sorted_bin./mu.con.unsorted_bin;
mu.mid.ratio(isnan(mu.mid.ratio))=0;
mu.con.ratio(isnan(mu.con.ratio))=0;

mu.mid.ratio(isinf(mu.mid.ratio))=0;
mu.con.ratio(isinf(mu.con.ratio))=0;
%%
figure;
subplot(211);plot(mu.con.ratio); title('control');
subplot(212);plot(mu.mid.ratio); title('midazolam');
%%
step_size = .5
figure;

subplot(211); hist(mu.con.ratio(mu.con.ratio>0),0:step_size:10);
subplot(212); hist(mu.mid.ratio(mu.mid.ratio>0),0:step_size:10);

%%  Only look at Multi Unit Burst Times:

mu.mid.mub = exp.midazolam.mub_times;
mu.con.mub = exp.control.mub_times;

for epo = {'mid', 'con'}
    ep = epo{:};
    time = mu.(ep).bins;
    ind = nan(length(time),1); % indecies of the mub events
    index = 0;
    for i=1:length(mu.(ep).mub)
        mu_time = mu.(ep).mub(i,:);
        index = index+1;
        valid_times = mu_time(1)<time & mu_time(2)>time; % which times are within the mub time
        n_times = sum(valid_times); % number of timestamps that are valid
        ind(index:index+n_times-1) = find(valid_times);
    end
    ind = ind(~isnan(ind));
    mu.(ep).mub_ind = ind;
end

%%  Using ONLY Multi Unit burst times
step_size = .5;
figure;
subplot(211); plot(mu.con.ratio(mu.con.mub_ind));title('control');
subplot(212); plot(mu.mid.ratio(mu.mid.mub_ind));title('midazolam');



