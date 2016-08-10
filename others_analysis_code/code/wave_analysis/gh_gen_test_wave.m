samplerate = 400;
timerange = [0, 40];
keep_timerange = [20 21];
ts = linspace(timerange(1),timerange(2),samplerate*diff(timerange));

n_chan = 18;
n_t = numel(ts);

% beta: f, lam, the, phi, amp
beta = [8, 10, -pi/4, pi, 0.1];

noise_level = 0.2;


tmp_eeg.chanlabels = {'a1','a2','b1','b2','c1','c2','d1','d2','e1','e2','f1','f2','g1','g2','h1','h2','i1','i2'};
tmp_eeg.data = zeros(size(tmp_eeg.chanlabels));
trodexy = mk_trodexy(tmp_eeg,esm_rat_conv_table);

x = [ reshape( repmat(ts,n_chan,1), [],1), repmat(trodexy,n_t,1)];
y = plane_wave_model(beta,x) + noise_level .* randn(size(x,1),1);

tmp_eeg = imcont('timestamp',ts,'data',transpose(reshape(y,n_chan,n_t)));
tmp_eeg.chanlabels = {'a1','a2','b1','b2','c1','c2','d1','d2','e1','e2','f1','f2','g1','g2','h1','h2','i1','i2'};
tmp_eeg.data = double(tmp_eeg.data);

if(0)
for n = 1:n_t
    n
    x = trodexy(:,1);
    y = trodexy(:,2);
    z = tmp_eeg.data(n,:);
    plot3(x,y,z,'.','MarkerSize',6);
    zlim([-4,4]);
    pause(1/20);
end
end

[tmp_theta,tmp_phase,tmp_env] = gh_theta_filt(tmp_eeg);

test_eeg.raw = contwin(tmp_eeg,keep_timerange);
test_eeg.theta = contwin(tmp_theta,keep_timerange);
test_eeg.phase = gh_clean_phase(contwin(tmp_phase,keep_timerange));
test_eeg.env = contwin(tmp_env,keep_timerange);

%plot(conttimestamp(tmp_eeg),tmp_eeg.data(:,6))
