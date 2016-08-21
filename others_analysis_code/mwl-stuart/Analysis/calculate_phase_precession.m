function data = calculate_phase_precession(exp, varargin)

args.eeg_ch = 1;
args = parseArgs(varargin, args);
epochs = exp.epochs;
e_ch = args.eeg_ch;

for e = epochs
    
    e = e{:}; %#ok
    data.(e) = struct;
    
    theta_filt = getfilter(exp.(e).eeg(e_ch).fs, 'theta', 'win');
    disp([e, ': filtering theta']);
    theta = filtfilt(theta_filt, 1, exp.(e).eeg(e_ch).data);
    disp([e, ': computing theta phase']);
    theta_phase = angle(hilbert(theta));
    
    disp([e, ': computing theta phase for each clusters']);
    for i=1:length(exp.(e).clusters)
        cl = exp.(e).clusters(i);
        cl.t_phase = interp1(exp.(e).eeg_ts, theta_phase, cl.time);
        cl.pos = interp1(exp.(e).position.timestamp, exp.(e).position.lin_pos, cl.time);
        cl.vel = interp1(exp.(e).position.timestamp, exp.(e).position.lin_vel, cl.time);
        
        ind = (cl.vel)>=.1;
        [sum(ind) length(ind)];
        
        cl.t_phase = cl.t_phase(ind);
        cl.pos = cl.pos(ind);
        cl.vel = cl.vel(ind);
        data.(e).cl(i) = cl;
    end
end
        