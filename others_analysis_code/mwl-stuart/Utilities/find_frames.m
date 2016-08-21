function frame_times = find_frames(mua,pos, varargin)
% returns a list of frame start and frame stop times, based upon multi-unit
% firing rate and velocity.  
%
%  bin_width and vel_thold can be specified
%  default bin_width is .005 seconds or 5 millieseconds
%  default vel_thold is .1 or 10 centemeters a second


disp ('DEPRICATED REPLACD WITH find_mu_burst');


args  = struct('bin_width', .005, 'vel_thold', .10);
if ~isempty(varargin)
    args = parseArgsLite(args, varargin);
end

bin_width=args.bin_width;
vel_thold=args.vel_thold;

[mx tx mur mut] = calculate_crossings(mua, pos, bin_width, vel_thold);

[b n] = inseg(mx,tx);
mub_times = mx(logical(n),:);

frame_times = mub_times;

    function [mx tx mu_rate mu_ts] = calculate_crossings(mua, pos, bin_width, vel_thold)        
        
        ts = mua(1);
        te = mua(end);

        mu_rate = histc(mua,ts:bin_width:te)/bin_width;
        mu_rate = smoothn(mu_rate, .01, bin_width);
        mu_ts = ts:bin_width:te;

        stopped = calculate_velocity(pos.linear_position, 0, .25, 1/30)<vel_thold;
        stop_seg = logical2seg(pos.timestamp, stopped);
        
        mu_stopped = logical(interp1(pos.timestamp, stopped, mu_ts, 'nearest'));
        [size(mu_stopped) size(mu_rate)];
        mu_rate_stopped = mu_rate(mu_stopped);
        mu_ts_stopped = mu_ts(mu_stopped);
        %plot(mu_rate_stopped)

        mean_mu = mean(mu_rate_stopped);
        thold = mean_mu+3*std(mu_rate_stopped);
        
        %plot(mu_rate_stopped>mean_mu)
        mx = logical2seg(mu_ts_stopped, mu_rate_stopped>mean_mu);
        tx = logical2seg(mu_ts_stopped, mu_rate_stopped>thold);
    end
end




