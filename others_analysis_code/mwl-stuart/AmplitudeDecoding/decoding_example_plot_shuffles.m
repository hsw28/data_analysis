input.method{2} = 'Shuffled Spike Amplitudes';
nShuffle = 500

%% Plot the example
plot_decoding_example(input,output, nShuffle, 'time_range', [4723.4 4803]);
%%
%%
miBins = 0:.02:3;

h1 = histc(output.stats.mi(2:nShuffle+1),miBins);
h2 = histc(output.stats.mi(nShuffle+2:end),miBins);

h1 = smoothn(h1/sum(h1),3);
h2 = smoothn(h2/sum(h2),3);

figure; 
plot(miBins, h1, 'b', miBins,h2, 'k', 'lineWidth', 2);
line( [output.stats.mi(1) output.stats.mi(1)], [0 .1], 'color', 'r', 'linewidth', 2);

xlabel('Mutual Information', 'FontSize', 14);
ylabel('Relative Frequency', 'FontSize', 14);



%% PDF of errors
%h1 = histc(output.stats.errors{1}, bins);
%h2 = histc(output.stats.errors{2}, bins);
%h3 = histc(output.stats.errors{3}, bins);


%h1 = smoothn(h1,3);
%h2 = smoothn(h2,3);
%h3 = smoothn(h3,3);

%figure; 
%plot(bins,h1, bins, h2, bins, h3);

%% save the data

%[directory date] = fileparts(exp.edir);
%[directory animal] = fileparts(directory);

%filename = ['Amp.Decoding.Example.With.Shuffles.', animal,'.',date, '.mat'];

%save(filename, 'input', 'output');

