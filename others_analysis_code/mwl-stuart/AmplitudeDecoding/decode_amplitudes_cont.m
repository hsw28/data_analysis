function [est tbins pbins p] = decode_amplitudes_cont(amps, pos, t_range, d_range, varargin)
%% Setup the decoder
a.dt = .3;
a.pos_bw = .1;
a.pos_k = 0;
a.pos_kw = .05;
a.amp_kw = 10;
a.vel_thold = .1;



a = parseArgsLite(varargin, a);

    %select spikes in the training range and moving spikes
amps_t = select_amps_by_feature(amps, 'feature', 'velocity',  'range', [a.vel_thold Inf]);
amps_t = select_amps_by_feature(amps_t, 'feature', 'ts',  'range', t_range);
    
spike_stim = cell(1,numel(amps_t));
spike_resp = cell(1,numel(amps_t));

for i=1:numel(amps_t)
    spike_stim{i} = amps_t{i}(:,6);
    spike_resp{i} = amps_t{i}(:,1:4);
end

stim_grid = min(pos):a.pos_bw:max(pos);

%% Decode

amps_d = select_amps_by_feature(amps, 'feature', 'ts', 'range', d_range);

t = d_range(1);
n = abs(diff(d_range))/a.dt;




tbins = d_range(1):a.dt:t;
if a.do_decoding
    warning off; %#ok
    wb = my_waitbar(0);
    for i=1:n
        
        tr = cell(0,numel(amps_d));
        for tt = 1:numel(amps_d)
            ind = amps_d{tt}(:,5)>=t & amps_d{tt}(:,5)<t+a.dt;
            tr{tt} = amps_d{tt}(ind,1:4);
        end
        est(:,i) = p.decode(tr, a.dt);
        t = t+a.dt;
        
        wb = my_waitbar(i/n,wb);
    end
    if ishandle(wb)
        close(wb);
    end
    warning on; %#ok
end

tbins = d_range(1):a.dt:d_range(2);
pbins = p.stimulus_grid{1};

end
    
    
    
    
    
    
    
    
    
    
    
    
    

    
    
    
