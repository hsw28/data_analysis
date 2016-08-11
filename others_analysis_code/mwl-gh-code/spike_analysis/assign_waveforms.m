function new_sdat = assign_waveforms(sdat)

nclust = numel(sdat.clust);

this_from_tt_file = '';
for i = 1:nclust
    if(not(strcmp(this_from_tt_file,sdat.clust{i}.from_tt_file)))
        this_from_tt_file = sdat.clust{i}.from_tt_file;
        disp(['Loading new tt file: ', this_from_tt_file]);
        this_tt_data = tt2mat(this_from_tt_file);
    end
%    spike_index = sdat.clust{i}.data(:,1);
%    waveforms = this_tt_data.waveform(:,:,spike_index);
%    sdat.clust{i}.waveforms = waveforms;
end
new_sdat = sdat;