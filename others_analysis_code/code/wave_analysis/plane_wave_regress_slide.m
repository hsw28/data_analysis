function [betahat, betahat_low, betahat_high, r] = plane_wave_regress_slide(sdat,rat_conv_table,varargin)

p = inputParser();
p.addParamValue('global_window',[sdat.tstart,sdat.tend],@isvector);
p.addParamValue('frame_length',0.25,@isscalar);
p.addParamValue('step_length',0.25,@isscalar);
p.addParamValue('finish_hanging_frame',false,@islogical);
p.parse(varargin{:});
opt = p.Results;

start_times = opt.global_window(1):opt.step_length:opt.global_window(2);

if(and( (not(opt.finish_hanging_frame)), (start_times(end) + opt.frame_length > opt.global_window(2))  ))
    start_times = start_times(1:end-1);
end
end_times = start_times + opt.frame_length;
nframes = numel(start_times);

betahat = NaN(nframes,4);
betahat_low = betahat;
betahat_high = betahat;

for m = 1:nframes
    [betahat, r, J, COVB, mse] = plane_wave_regress_frame(contwin(sdat,[start_times(m),end_times(m)]),rat_conv_table,'draw',false,'report_ci',false);
    this_ci = nlparci(betahat,r,'jacobian',J);
    betahat_low(m,:) = this_ci(:,1)';
    betahat_high(m,:) = this_ci(:,2)';
end

betahat = imcont('timestamp',mean([start_times;end_times],1),'data',betahat);
betahat_low = imcont('timestamp',mean([start_times;end_times],1),'data',betahat_low);
betahat_high = imcont('timestamp',mean([start_times;end_times],1),'data',betahat_high);
