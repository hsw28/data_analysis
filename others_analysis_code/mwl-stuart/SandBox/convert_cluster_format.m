function [c ns] = convert_cluster_format(spike_times, pos, vel, pts, varargin)
    a.vel_thold = 0.1;
    a.filter_by_velocity = 1;
    a.min_spike_allowed = 75;
    a = parseArgsLite(varargin,a);
    
    
    c = cell(1,numel(spike_times));
    ind = logical(1:numel(c));
    
    for i=1:numel(c)
        nspike = numel(spike_times{i});
        c{i}(:,1) = ones(nspike,1)*i;                %1 - CL ID
        c{i}(:,2) = spike_times{i};                  %2 - Spike time
        c{i}(:,3) = interp1(pts,pos,spike_times{i}); %3 - Position
        c{i}(:,4) = interp1(pts,vel,spike_times{i}); %4 - Velocity
        
        if sum(abs(c{i}(:,4))>=a.vel_thold)<75
            ind(i) = 0;
        end
    end
    if a.filter_by_velocity
        c = c(ind);
    end
    
    ns = 0;
    for i=1:numel(c)
        ns = ns + numel(c{i}(:,1));
    end
   
end
