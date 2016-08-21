%% - Calculate average frequency for Two epochs
clear calc;
file_path = '/home/slayton/data/disk1/fab/fk18/day09/extracted_data/eeg1_09.eeg';
eeg_file = mwlopen(file_path);
ch = 2;
gain = load_eeg_gains(file_path, ['channel', num2str(ch)], 2);
spread = .5;
ripple_len = .1;
rfilt = nan;
n_rand_sample=1000;

method = 'peak';
tic;
for epoch = {'midazolam', 'control'}
    ep = epoch{:};
    
    rip_ind = randsample(length(exp.(ep).ripple_times),n_rand_sample, true);
    mean_freq = nan(n_rand_sample,1);
    calc.(ep).freqs  = nan(n_rand_sample,1);
    
    for i = 1:length(rip_ind)
        ind = rip_ind(i);
        trig =  exp.(ep).ripple_times(ind);
        [eeg ts fs] = load_raw_eeg(eeg_file, gain, ch, trig-spread, trig+spread); 

        if isnan(rfilt)
            rfilt = getfilter(fs, 'ripple','win');
        end
        
        filtered_eeg = filtfilt(double(rfilt), 1, eeg);
        switch method
            case 'hilbert'
                % hilbert Method
                inst_f =  gradient( unwrap( angle( hilbert(filtered_eeg))), 1/fs ) ./ (2*pi); 
                ts_n = ts;
                
                calc.(ep).freqs(i) = mean(inst_f(ts_n>=trig-ripple_len & ts_n<=trig+ripple_len));
            case 'peak'
                % Peak Detection Method
                [peak_vals peak_ind] = findpeaks(filtered_eeg);
                inst_f = (1./gradient(ts(peak_ind))); 
                ts_n = ts(peak_ind); 
                calc.(ep).freqs(i) = mean(inst_f(ts_n>=trig-ripple_len & ts_n<=trig+ripple_len));
        end
    end
end
toc;
%% Plot differences in Epochs

bins = 150:5:200;

for epoch = {'midazolam', 'control'}
    ep = epoch{:};
    calc.(ep).hist = histc(calc.(ep).freqs, bins);
end
figure;
plot(bins, calc.midazolam.hist, 'k', 'LineWidth', 2); hold on;
plot(bins, calc.control.hist, 'r', 'LineWidth', 2); hold off;
legend('Midazolam', 'Control');



%%  - Plot Ripple at 500hz, 2khz, hilbert envelope and estimated freq
clear a;
figure; 
epochs = {'control', 'midazolam'};
ep = epochs{1};

r_n = randsample(length(exp.(ep).ripple_times),1);
r_n = 57;
trig =  exp.(ep).ripple_times(r_n);
spread = .75;

set(gcf, 'Position', [150 450 1300 800]);
subplot(411);
title(r_n);
wave_browser(exp.(ep).eeg(1).data, exp.(ep).eeg_ts); 
hold on; 
eb = event_browser(exp.(ep).ripple_times,0); 
eb.Color='r';
a(1)  = gca();

subplot(412);
f = '/home/slayton/data/disk1/fab/fk18/day09/extracted_data/eeg1_09.eeg';

[eeg ts] = load_raw_eeg(f, ch, trig-spread, trig+spread); plot(ts,eeg);
eb = event_browser(exp.(ep).ripple_times,0); eb.Color = 'r';
a(2) = gca();

subplot(413); 
filtered_eeg = filtfilt(double(rfilt), 1, eeg);
plot(ts, filtered_eeg); hold on;
eb = event_browser(exp.(ep).ripple_times,0); 
eb.Color='r';
a(3) = gca();

subplot(414);
plot(ts,smoothn( gradient( unwrap( angle( hilbert(filtered_eeg))), 1/fs ), .0125, 1/fs) ./ (2*pi))
a(4) = gca();

linkaxes(a, 'x');
set(a,'XLim', [min(ts) max(ts)]);


%% - Compare different methods and STD for calculating the Inst Freq
% A plot used to figure out what st.d. to use for the smoothing of
% theinstant Frequency analysis
figure; clear a;
subplot(211);
a(1) = gca();
inst_f =  gradient( unwrap( angle( hilbert(filtered_eeg))), 1/fs ) ./ (2*pi); t = ts; fs_n = mean(gradient(t));

plot(t, inst_f, 'c','LineWidth',3); hold on; title('Instant Freq Estimate Using hilbert method');
s = [.0025, .005, .01]; 
plot(t,smoothn(inst_f, s(1), fs_n),'r','LineWidth',3);
plot(t,smoothn(inst_f, s(2), fs_n),'g','LineWidth',3);
plot(t,smoothn(inst_f, s(3), fs_n),'k','LineWidth',3);

legend('raw',num2str(s(1)), num2str(s(2)), num2str(s(3)));
hold off;

inst_f = (1./gradient(ts(b))); t = ts(b); fs_n = mean(gradient(t));
subplot(212);
a(2) = gca();
plot(t, inst_f, 'c','LineWidth',3); hold on; title('Instant Freq Estimate Using peak detect');
s = [.0025, .005, .01]; 
plot(t,smoothn(inst_f, s(1), fs_n),'r','LineWidth',3);
plot(t,smoothn(inst_f, s(2), fs_n),'g','LineWidth',3);
plot(t,smoothn(inst_f, s(3), fs_n),'k','LineWidth',3);

legend('raw',num2str(s(1)), num2str(s(2)), num2str(s(3)));
hold off;
linkaxes(a, 'x');
















