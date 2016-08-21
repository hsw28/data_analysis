function clust = calc_cluster_stats(exp, epoch)
    
    clust = exp.(epoch).clusters;
    pos = exp.(epoch).position;
    for i=1:numel(clust)
        [clust(i).mean_rate_run, clust(i).mean_rate_stop] = ...
             calc_mean_fr(clust(i), pos);
    end


end

function [run_rate stop_rate] = calc_mean_fr(cluster, pos)

    spike_vel = interp1(pos.timestamp, pos.lin_vel, cluster.time);
    spike_vel(isnan(spike_vel)) = 7;
    
    n_spike_run = sum(abs(spike_vel)>=.10);
    n_spike_stop= sum(abs(spike_vel)<=.05);
   
    dt = 1/30;
    
    run_ind = abs(pos.lin_vel)>=.10;
    stop_ind = abs(pos.lin_vel)<=.05;


    time_stopped = sum(stop_ind)*dt;
    time_running = sum(run_ind)*dt;
    
    run_rate  = n_spike_run ./time_running;
    stop_rate = n_spike_stop./time_stopped;
    

end