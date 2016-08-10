function [cells,skipped] = quick_get_waveform(sdat,varargin)
p = inputParser();
p.addParamValue('index',[]);
p.addParamValue('old_cells',[]);
p.addParamValue('spike_count_limit',10000000)
p.parse(varargin{:});
opt = p.Results;

max_spikes = 10000;
skipped = [];
for n = 1:numel(sdat.clust)
    
    %cells(n).waveforms = zeros(numel(sdat.clust),1 + 1 + 4*32); % time, unit id, waveform chan1 : waveform chan4
    
    trode_name = sdat.clust{n}.trode;
    ttf = mwlopen([trode_name,'/',trode_name,'.tt']);
    pxyabwf = mwlopen([trode_name,'/',trode_name,'.pxyabw']);
    inds = sdat.clust{n}.data(:,1);
    if(numel(inds) > 20000)
        inds = inds(1:20000);
    end
    
    if(numel(inds) <= opt.spike_count_limit)
        all_timestamps = double(ttf.timestamp)/10000;
        all_waveforms = (ttf.waveform);
    %all_timestamps = (LOAD(ttf,'timestamp',inds))/10000;
    %all_waveforms = (LOAD(ttf,'waveform',inds));
    
    this_wf = all_waveforms(:,:,inds);
    clear all_waveforms;
    this_wf = double(this_wf);
    cells(n).waveforms = this_wf;
    clear this_wf;
    clear ttf;
    clear pxyabwf;
    
    ts_from_tt = all_timestamps(inds);
    clear inds;
    ts_from_pxyabw = sdat.clust{n}.data(:,8);
    
    %ts_diff = reshape(ts_from_tt,1,[]) - reshape(ts_from_pxyabw,1,[]);
    n
    %min(ts_diff)
    %max(ts_diff)
    
    cells(n).timestamps = ts_from_tt;
    else
        skipped = [skipped, n]
    end
    %for m = 1:size(sdat.clust{n}.data,1)
    %    this_time = sdat.clust{n}.data(m,8);
    %    this_bool = this_time == all_timestamps;
    %    this_ind = find(this_bool);
    %    
    %    this_clust_timestamps = all_timestamps(this_ind);
    %    this_clust_waveforms = all_waveforms(:,:,this_ind);
    %    this_ts_check = pxyabwf.time;
    %    this_ts_check = this_ts_check(this_ind);
   % 
   %     waveforms = [this_clust_timestamps(this_ind), n, reshape(this_clust_waveforms,1,[])];
   % end
end