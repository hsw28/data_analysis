function times = find_run_times(exp, varargin)
% times = find_stop_times(exp) 
% times = find_stop_times( ... , 'threshold', thold) 
% times = find_stop_times( ... , 'epochs', {epoch_list}
%
% find_stop_timesreturns a 2xN vector of stop_times
% with the first column containing the timestamp of the start stopping and
% the second coloum containing timestamp of the end of the stopping period
%
%
args.threshold =.03;
args.epoch_list = exp.epochs;
args = parseArgs(varargin, args);

for ep = args.epoch_list
    e = ep{1};
    times.(e) = logical2seg(exp.(e).position.timestamp, abs(exp.(e).position.lin_vel)<args.threshold);
end
