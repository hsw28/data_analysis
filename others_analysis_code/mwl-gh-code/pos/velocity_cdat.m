function c = velocity_cdat(pfilename,efilename,varargin)
% 

p = inputParser();
p.addParamValue('smooth_t',0.5);
p.addParamValue('drop_zero', true);
p.addParamValue('timewin',[]);
p.addParamValue('draw',false);
p.addParamValue('denoise',[]);
p.addParamValue('camScales',defaultCamScales());
p.addParamValue('epochCams',defaultEpochCams());
p.parse(varargin{:});
opt = p.Results;

epochTimes = loadMwlEpoch('filename',efilename);
epochScales = mapCompose(opt.camScales, opt.epochCams);
epochs = epochTimes.keys;
nEpoch = numel(epochs);

[ts,x,y,ang,heading,validity,xfront,yfront,xback,yback,xvel,yvel] = clean_raw_pos(pfilename,'drop_zero',opt.drop_zero);

v = sqrt(yvel .^ 2 + xvel .^ 2);

scales = NaN * ones(size(v));

for n = 1:nEpoch
    this_epoch_bool = gh_points_are_in_segs(ts, {epochTimes(epochs{n})} );
    scales(this_epoch_bool) = epochScales(epochs{n});
end

v = v .* scales;

v(isnan(v)) = 0;
c = imcont('timestamp',ts','data',v');
c.chanlabels = {'velocity'};

if ~isempty(opt.smooth_t)
    c = gh_smooth_cont(c, opt.smooth_t);
end

c.data(isnan(scales)) = NaN;

if(opt.draw)
    ax(1) = subplot(3,1,1);
    plot(ts,x);
    ax(2) = subplot(3,1,2);
    plot(ts,y);
    ax(3) = subplot(3,1,3);
    gh_plot_cont(c,'zero_nans',true);
    linkaxes(ax,'x');
end