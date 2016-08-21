function [est ts pbins edges p] = decode_amplitudes_par(amps, pos, t_range, d_range, varargin)
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


if ~isa(a.decoder, 'poisson_decode')
    
    %select spikes in the training range and moving spikes
    amps_t = select_amps_by_feature(amps, 'feature', 'col',   'col_num', 7, 'range', [a.vel_thold Inf]);
    amps_t = select_amps_by_feature(amps_t, 'feature', 'col', 'col_num', 5, 'range', t_range);
    
    valid_amps = ~cellfun(@isempty, amps_t);
    
    amps = amps(valid_amps);
    amps_t = amps_t(valid_amps);
    
    spike_stim = cell(1,numel(amps_t));
    spike_resp = cell(1,numel(amps_t));

    for i=1:numel(amps_t)
       spike_resp{i} = amps_t{i}(:,a.resp_col);
       spike_stim{i} = amps_t{i}(:,6);
    end
    
    stim_grid = min(pos)+a.pos_bw/2:a.pos_bw:max(pos);

  
    p = poisson_decode(abs(diff(t_range)), pos, spike_stim, spike_resp,...
        'stimulus_kernel_type', a.pos_k, ...
        'stimulus_kernel_width', a.pos_kw, ...
        'response_kernel_type', a.amp_k, ...
        'response_kernel_width', a.amp_kw, ...
        'stimulus_grid', {stim_grid});
else 
    p = a.decoder;
end
%% Decode

if a.do_decoding

    amps_d = select_amps_by_feature(amps, 'feature', 'col','col_num',5, 'range', d_range);

    n = floor(abs(diff(d_range))/a.dt);
    
    ts = d_range(1)+a.dt/2:a.dt:d_range(2);
    pbins = p.stimulus_grid{1};
        
    est = zeros(numel(pbins),numel(ts));

    if a.wb
        wb = my_waitbar(0, [], 'color', a.wb_color);
    end
    
    warning off; %#ok
    
    parfor i=1:n
        tr = cell(0,numel(amps_d));
        for tt = 1:numel(amps_d)
            ind = amps_d{tt}(:,5)>=ts(i)-a.dt/2 & amps_d{tt}(:,5)<ts(i)+a.dt/2; %#ok
            tr{tt} = amps_d{tt}(ind,a.resp_col);
        end
        
        est(:,i) = p.decode(tr, a.dt); %#ok
        
        if a.wb
            wb = my_waitbar(i/n,wb);
        end
    end
    if a.wb
       if ishandle(wb)
           close(wb);
       end
    end
    warning on; %#ok

    est = est(:,1:n);
    edges.time = [ts - a.dt/2 , ts(end)+a.dt/2];
    dp = mean(diff(pbins));
    edges.pos = [pbins-dp/2 pbins(end)+dp/2];
else
    est = [];
    ts = [];
    pbins = [];
    edges = [];
end

end
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
