% 
% exp13 = loadexp('/data/spl11/day13', 'epochs', 'amprun', 'data_types', {'clusters', 'pos'});
% exp14 = loadexp('/data/spl11/day14', 'epochs', 'amprun', 'data_types', {'clusters', 'pos'});
% exp15 = loadexp('/data/spl11/day15', 'epochs', 'amprun', 'data_types', {'clusters', 'pos'});
% exp16 = loadexp('/data/spl11/day16', 'epochs', 'amprun', 'data_types', {'clusters', 'pos'});
%%
% 
% amps13 = load_tetrode_amps(exp13, 'amprun');
% amps14 = load_tetrode_amps(exp14, 'amprun');
% amps15 = load_tetrode_amps(exp15, 'amprun');
% amps16 = load_tetrode_amps(exp16, 'amprun');
% %%
% cl13 = convert_cl_to_kde_format(exp13,'run');
% cl14 = convert_cl_to_kde_format(exp14,'run');
% cl15 = convert_cl_to_kde_format(exp15,'run');
% cl16 = convert_cl_to_kde_format(exp16,'run');
% 
% %%
% a{1}= amps13;
% a{2} = amps14;
% a{3} = amps15;
% a{4} = amps16;
% %%
% a{1}= cl13;
% a{2} = cl14;
% a{3} = cl15;
% a{4} = cl16;
%%
a{1} = input.data{1};

%%
n_spike = 0;
for i=1:numel(a)
    n_spike = sum(cellfun(@numel, a{i}));
end
%%
my_fun = @nothing;
amps = ones(n_spike,4);
ind = 1;
for i=1:numel(a)
    for j=1:numel(a{i})
        d = my_fun(a{i}{j}(:,1:4));
        n = size(d,1);
        amps(ind:ind+n-1,:) = d;
        ind = ind+n+1;
    end
end
%%
min_volt = 75; min_volt = my_fun(min_volt);
ind = max(amps,[],2)>=min_volt;
amps = amps(ind,:);

%%
bins = 75:5:1000; bins = my_fun(bins);
amps_dist = histc(amps(:,1),bins);
amps_dist = amps_dist/numel(amps(:,1));
%%
figure('Position', [767 198 831 902]); 

subplot(411);
area(bins, amps_dist, 'HandleVisibility', 'off' , 'facecolor', 'b', 'edgecolor', 'b');

hist_lims = [75 700]; hist_lims = my_fun(hist_lims);
set(gca,'XLim', hist_lims, 'YLim', [0 .12], 'fontsize', 16);
ylabel('Percentage of Spikes', 'fontsize', 16);
xlabel('Spike Amplitude', 'fontsize', 16);

a1 = 100; a1 = my_fun(a1);
a2 = 125; a2 = my_fun(a2);
a3 = 150; a3 = my_fun(a3);


line([a1 a1], [0 .2], 'color', 'r', 'linewidth', 2, 'linestyle', '-');
line([a2 a2], [0 .2], 'color', 'r', 'linewidth', 2, 'linestyle', '--');
line([a3 a3], [0 .2], 'color', 'r', 'linewidth', 2, 'linestyle', '-.');


i1 = bins>a1;
i2 = bins>a2;
i3 = bins>a3;

s1 = floor(sum(amps_dist(i1))*1000)/10;
s2 = floor(sum(amps_dist(i2))*1000)/10;
s3 = floor(sum(amps_dist(i3))*1000)/10;
legend({ ['100 uV - ', num2str(s1), '%'], ['125 uV - ', num2str(s2), '%'],['150 uV - ', num2str(s3), '%']});

if size(amps,1)>1e6
    spike_sample = randsample(size(amps,1), 1e6);
else
    spike_sample = logical(1:size(amps,1));
end

subplot(4,1,2:4);
plot(amps(spike_sample,3), amps(spike_sample,2), '.', 'markersize', 1, 'HandleVisibility', 'off');
line([0 a1 a1], [a1 a1 0],  'color', 'r', 'linewidth', 2, 'linestyle', '-');
line([0 a2 a2], [a2 a2 0],  'color', 'r', 'linewidth', 2, 'linestyle', '--');
line([0 a3 a3], [a3 a3 0],  'color', 'r', 'linewidth', 2, 'linestyle', '-.');

xl = 900; xl = my_fun(xl);
yl = 900; yl = my_fun(yl);

set(gca,'XLim', [0 xl], 'YLim', [0 yl]);

xlabel('Amplitude 1', 'fontsize', 16);
ylabel('Amplitude 2' , 'fontsize', 16);
set(gca,'FontSize', 16);
%%
set(gcf,'Name', 'Total Amplitude Distribution');
%%
set(gcf,'Name', 'Cluster Amplitude Distribution');