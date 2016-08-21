function [est tbins pbins p] = decode_clusters(amps, pos, t_range, d_range, varargin) 
%% Setup the decoder
a.dt = .25;
a.pos_bw = .1;
a.pos_k = 0;
a.pos_kw = .05;
a.amp_k = [0 0 0 0];
a.amp_kw = [10 10 10 10];
a.vel_thold = .1;
a.decoder = [];
a.do_decoding = 1;
a.extra_col = 0;
a.wb = 0;
a.ignore_amplitudes = 0;
resp_col = 1:4;

a = parseArgsLite(varargin, a);

a.wb = logical(a.wb);
a.ignore_amplitudes = logical(a.ignore_amplitudes);

if a.ignore_amplitudes
    disp('Ignoring Amplitudes');
    a.amp_k = [];
    a.amp_kw = []; 
end

if a.extra_col
    resp_col = [resp_col a.extra_col];
end

if ~isa(a.decoder, 'poisson_decode')
    
    %select spikes in the training range and moving spikes
    amps_t = select_amps_by_feature(amps, 'feature', 'col',   'col_num', 7, 'range', [a.vel_thold Inf]);
    amps_t = select_amps_by_feature(amps_t, 'feature', 'ts', 'range', t_range);
    valid_amps = ~cellfun(@isempty, amps_t);
    
    amps = amps(valid_amps);

    amps_t = amps_t(valid_amps);
    
    spike_stim = cell(1,numel(amps_t));
    spike_resp = cell(1,numel(amps_t));


    for i=1:numel(amps_t)
        switch a.ignore_amplitudes 
            case 0
                spike_resp{i} = amps_t{i}(:,resp_col);
            case 1
                spike_resp{i} = ones(size(amps_t{i},1),0);
        end
        spike_stim{i} = amps_t{i}(:,6);
    end

    stim_grid = min(pos):a.pos_bw:max(pos);

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

    amps_d = select_amps_by_feature(amps, 'feature', 'ts', 'range', d_range);

    t = d_range(1);
    n = abs(diff(d_range))/a.dt;

    tbins = d_range(1):a.dt:d_range(2);
    pbins = p.stimulus_grid{1};
    
    est = zeros(numel(pbins),numel(tbins));
    
    if a.wb
        wb = my_waitbar(0);
    end
    
    %warning off; %#ok
    
    for i=1:n
        tr = cell(0,numel(amps_d));
        for tt = 1:numel(amps_d)
            ind = amps_d{tt}(:,5)>=t & amps_d{tt}(:,5)<t+a.dt;
        
            switch a.ignore_amplitudes
                case 0
                    tr{tt} = amps_d{tt}(ind,resp_col);
                case 1    
                    tr{tt} = ones(sum(ind),0);             
            end
        end
    
        est(:,i) = p.decode(tr, a.dt);
        t = t+a.dt;

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

else
    est = [];
    tbins = [];
    pbins = [];
end

end
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
