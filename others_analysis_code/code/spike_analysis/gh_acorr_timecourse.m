function [t,surface,measure,opt] = gh_acorr_timecourse(spikes,varargin)

p = inputParser();

p.addParamValue('time_centers',[]); % time points to measure acorr
p.addParamValue('time_widths',[]); % window around each point to measure acorr

p.addParamValue('view',[]); % acorr width to calculate for each timepoint.  Smaller view = easier to calc acorr
p.addParamValue('bin_size',[]); % how small to dice up spikes into count timecourses for acorr

p.addParamValue('measure_range',[]); % amount to average r over in r by dt. units = ms

p.addParamValue('gh_acorr_timecourse_opts',[]); % allow for overriding defaults by saved opts

p.parse(varargin{:});

if(~isempty(p.Results.gh_acorr_timecourse_opts)) % first try override
    opt = p.Results.gh_acorr_timecourse_opts;
else
    opt = p.Results;
end

if(~isempty(opt.measure_range))
    if(isempty(opt.view))
        opt.view = 1.2 * max(opt.measure_range);
    end
    if(isempty(opt.bin_size))
        opt.bin_size = 0.2 * min(opt.measure_range)
    