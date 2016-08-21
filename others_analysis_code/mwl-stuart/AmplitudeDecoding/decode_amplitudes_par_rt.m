function [est ts pbins elTime nS nT] = decode_amplitudes_par_rt(amps, pos, t_range, varargin)
%% Setup the decoder
a.dt = .25;
a.pos_bw = .1;
a.pos_k = 0;
a.pos_kw = .05;
a.amp_k = [0 0 0 0];
a.amp_kw = [30 30 30 30];
a.vel_thold = .05;
a.decoder = [];
a.do_decoding = 1;
a.wb = 0;
a.ignore_amplitudes = 0;
a.wb_color = 'r';
a.resp_col = 1:4;

a = parseArgsLite(varargin, a);
a.amp_k = a.amp_k(a.resp_col);
a.amp_kw = a.amp_kw(a.resp_col);

a.wb = logical(a.wb);
a.ignore_amplitudes = logical(a.ignore_amplitudes);

if isempty(a.resp_col)
    disp('Ignoring Amplitude Information');
    a.amp_k = [];
    a.amp_kw = [];
end


ts = t_range(1):a.dt:t_range(2);

n = abs(diff(t_range))/a.dt;

pbins = 0:a.pos_bw:max(pos.lp);
est = cell(n,1);

amps = select_amps_by_feature(amps, 'feature', 'col',   'col_num', 7, 'range', [a.vel_thold Inf]);

elTime = nan(n,1);
nS = nan(n,1);
nT = nan(n,1);

parfor i=1:(n-1)

    
    %select spikes in the training range and moving spikes
%   amps_t = select_amps_by_feature(amps, 'feature', 'col',   'col_num', 7, 'range', [a.vel_thold Inf]);
%   amps_t = select_amps_by_feature(amps_t, 'feature', 'col', 'col_num', 5, 'range', t_range);
    
%    valid_amps = ~cellfun(@isempty, amps_t);
    
  %  amps = amps(valid_amps);
  % amps_t = amps_t(valid_amps);
    
    t1 = max([ts(i)-180, ts(1)]);
    amps_t = select_amps_by_feature(amps,'feature', 'col','col_num',5,'range', [t1 ts(i)]);
    spike_stim = cell(1,numel(amps_t));
    spike_resp = cell(1,numel(amps_t));

    nSource = 0
    for idx=1:numel(amps_t)
       spike_resp{idx} = amps_t{idx}(:,a.resp_col);
       spike_stim{idx} = amps_t{idx}(:,6);
       nSource = nSource + numel(spike_resp{idx});
    end
    nS(i) = nSource;
    
    stim_grid = min(pos.lp)+a.pos_bw/2:a.pos_bw:max(pos.lp);
    
    
    p = poisson_decode(abs(diff(t_range)), pos.lp', spike_stim, spike_resp,...
        'stimulus_kernel_type', a.pos_k, ...
        'stimulus_kernel_width', a.pos_kw, ...
        'response_kernel_type', a.amp_k, ...
        'response_kernel_width', a.amp_kw, ...
        'stimulus_grid', {stim_grid});
 

%% Decode

    d_range = [ts(i) ts(i+1)]
    amps_d = select_amps_by_feature(amps, 'feature', 'col','col_num',5, 'range', d_range);
    
    %pbins = p.stimulus_grid{1};
        

   
    warning off; %#ok
    
    nTest = 0;
    tr = cell(0,numel(amps_d));
    for tt = 1:numel(amps_d)
        ind = amps_d{tt}(:,5)>=ts(i)-a.dt/2 & amps_d{tt}(:,5)<ts(i)+a.dt/2;
        tr{tt} = amps_d{tt}(ind,a.resp_col);
        nTest = nTest + numel(tr{tt});
    end
    nT(i) = nTest;
    
    tic;
    est{i} = p.decode(tr,a.dt);
    decode_time = toc;
    
    elTime(i) = decode_time;


    
end
        
   %  est = est(:,1:n);
   % edges.time = [ts - a.dt/2 , ts(end)+a.dt/2];
   % dp = mean(diff(pbins));
   % edges.pos = [pbins-dp/2 pbins(end)+dp/2];
end
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
