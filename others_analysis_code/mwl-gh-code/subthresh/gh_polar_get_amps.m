function [amps,ts] = gh_polar_get_amps(filename,varargin)
p = inputParser();
p.addParamValue('timewin',[]);
p.parse(varargin{:});
opt = p.Results;

this_file = mwlopen(filename);
ts = double(this_file.time)';
amps = [ this_file.t_px', this_file.t_py', this_file.t_pa', this_file.t_pb'];
amps = double(amps);

if(~isempty(opt.timewin))
    keep_log = ts >= min(opt.timewin) & ts <= max(opt.timewin);
    ts = ts(keep_log);
    amps = amps(keep_log,:);
end