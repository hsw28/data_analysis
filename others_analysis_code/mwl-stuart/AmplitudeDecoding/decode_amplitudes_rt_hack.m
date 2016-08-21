function [est tbins pbins] = decode_amplitudes_rt(amp_data, pos, t, varargin)
%% Setup the decoder
a.dt = .25;
a.pos_bw = .1;
a.pos_k = 0;
a.pos_kw = .05;
a.amp_k = [0 0 0 0];
a.amp_kw = [30 30 30 30];
a.vel_thold = .1;
a.decoder = [];
a.do_decoding = 1;
a.extra_col = 0;
a.start_time = 0;

a = parseArgsLite(varargin, a);

lp = pos.lp(:);
lp = remove_nan(lp);
pts = pos.ts(:);
pbins = min(lp):a.pos_bw:max(lp);
grid = pbins(:);

for i=1:numel(amp_data)
    moving = logical(abs(amp_data{i}(:,7))>=a.vel_thold);
    ts{i} = amp_data{i}(:,5);
    ts_moving{i} = ts{i}(moving);
    spikes{i} = amp_data{i};
    spikes_moving{i} = spikes{i}(moving);
end
       




if a.start_time ==0
    ct = t(1);
else
    ct = a.start_time;
end
tbins(1) = ct;

count =0;
est = [];
while ct<=t(2)-a.dt
    
    count = count +1;
    ct = ct+a.dt;
  
    [mu ns] = get_mu(t(1), ct, ts_moving);
    [spike_r spike_s] = get_spike_history_data(ct, spikes);
    [test_r] = get_spike_test_data(ct, a.dt, spikes);
    
    pos_ind = pts<ct;
    Pstim = compute_stimulus_pdf(lp(pos_ind));
    
    Pstimspike = cellfun( @compute_stimulus_pdf, spike_s, 'UniformOutput', false );
    % need to calculate Pstimspike
    % need to calculate Pstim

    est(:,count)= rt_decode(spike_r, spike_s, test_r, grid, ...
        a.amp_k, a.amp_kw, a.pos_k, a.pos_kw, ...
        mu, Pstimspike, Pstim, ns, a.dt );
    tbins(end+1) = ct;
end

%%   
%     spike_stim = cell(1,numel(amps_t));
%     spike_resp = cell(1,numel(amps_t));
% 
%     for i=1:numel(amps_t)
%         spike_stim{i} = amps_t{i}(:,6);
%         spike_resp{i} = amps_t{i}(:,1:4);
%     end
% 
%     grid = {min(pos):a.pos_bw:max(pos)};
% 
%     p = poisson_decode(abs(diff(t_range)), pos, spike_stim, spike_resp,...
%         'stimulus_kernel_type', a.pos_k, ...
%         'stimulus_kernel_width', a.pos_kw, ...
%         'response_kernel_type', a.amp_k, ...
%         'response_kernel_width', a.amp_kw, ...
%         'stimulus_grid', {stim_grid});
% else 
%     p = a.decoder;
% end
%% Decode
    function [resp stim] = get_spike_history_data(cur_time, spikes)
        resp = {};
        stim = {};
        for i = 1:numel(spikes);
           ind = spikes{i}(:,5)<cur_time;
           resp{i} = spikes{i}(ind,1:4);
           stim{i} = spikes{i}(ind,6);
        end
    end
    function [resp] = get_spike_test_data(cur_time, dt, spikes)
        resp = {};
        stim = {};
        for i = 1:numel(spikes);
           ind = spikes{i}(:,5)>=cur_time & spikes{i}(:,5)<(cur_time+dt);
           resp{i} = spikes{i}(ind,1:4);
        end
    end
    function [mu ns] = get_mu(start_t, cur_time, ts)
       
        t1 = start_t;
        t2 = cur_time;
        ns = cellfun(@within_time,ts, 'uniformoutput', 0);
        ns = cellfun(@sum, ns);
        dt = t2-t1;
        mu = ns/dt;
        ns = ns;
       
        function valid = within_time(ts)
            valid = ts>=t1 & ts< t2;
        end
    end
    function P = rt_decode(s_resp, s_stim, t_resp, grid, resp_k_type, resp_k_width,...
                stim_k_type, stim_k_width, mu, Pstimspike, Pstim, nspikes, dt)
        P = 0;

        for k=1:numel(t_resp)

            tmp = amp_decode4_c( s_resp{k}, s_stim{k}, t_resp{k},grid, ...
                resp_k_type, resp_k_width, stim_k_type, stim_k_width);
            warning off;
            tmp = sum(log(tmp),1) - nspikes(k).*log(Pstim);
            warning on;
            tmp = tmp - dt.*mu(k).*Pstimspike{k}./Pstim;
            
            P = P + tmp;

        end

        P = exp(P-nanmax(P));
        P = P./nansum(P(:));
    end
    function p = compute_stimulus_pdf(x)
        p = amp_decode4_c( zeros(size(x,1),0), x, zeros(1,0), grid, [], [], a.pos_k, a.pos_kw );
        p = p./sum(p(:));
    end

    function pos = remove_nan(pos)
        i = 1;
        while isnan(pos(1))
            pos(1) = pos(i);
            i = i+1;
        end

        while any(isnan(pos))
            pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
        end

    end
        
        
end