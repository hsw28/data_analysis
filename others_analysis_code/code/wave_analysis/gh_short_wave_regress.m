function [est, ci, r_squared] = gh_short_wave_regress(eeg,rat_conv_table,varargin)
% GH_SHORT_WAVE_REGRESS - fits a traveling wave model to short cdat window
%
% [est,ci,r_squared] = gh_short_wave_regress(eeg,rat_conv_table,varargin)
% Inputs:
% -eeg: an eeg_r struct
% -rat_conv_table: the output from a call to [rat]_conv_table
% -draw_data: boolean switch to make a movie with the filtered data points
% -fps: movie framerate
% -draw_shadow: a decoration on the movie
% -draw_model: draw the pre-regression param estimate model
% -timewin: limit the regression to a small window of cdat data
% -movname: pass a file name to write the movie to disk
% -spitlist: pass a list of frame indices to 'spit' out from the movie as
%  static figs
%
% Outputs:
% -est: 5x1 param estimates [freq, wavelength, angle, phase, amp]
% -ci: []
% -r_squared: 1xts vector of r_squared values for model fit
p = inputParser();
p.addParamValue('nlin_regress',true);
p.addParamValue('draw_data',false);
p.addParamValue('fps',20);
p.addParamValue('draw_shadow',[]);
p.addParamValue('draw_model',[]);
p.addParamValue('timewin',[]); % NOT commonly used - just for last-minute timewindowing
p.addParamValue('movname',[]); % give a movename string if you want an avi
p.addParamValue('spitlist',[]); % vector of frame # to spit out as still figs during movie
p.parse(varargin{:});
opt = p.Results;

if(~isempty(p.Results.timewin))
    eeg = contwin_r(eeg,p.Results.timewin);
end

n_time = size(eeg.raw.data,1);
n_chan = size(eeg.raw.data,2);

% set up independent variables and dependent variables
data = eeg.theta.data;

trodexy = mk_trodexy(eeg.raw,rat_conv_table);
pos = repmat(trodexy,n_time,1);

time = conttimestamp(eeg.raw);
time = reshape(time,[],1);
time = repmat(time,1,n_chan); % for 3 chans: [t1 t1 t1; t2 t2 t2; ...]
time = reshape(time',[],1); % for 3 chans: [t1; t1; t1; t2; t2; t2; ...]

x = [time,pos(:,1),pos(:,2)];
y = reshape(data',[],1);

b0 = plane_wave_guess_beta(eeg,trodexy,'x',x,'y',y,'draw_data',p.Results.draw_data,'fps',p.Results.fps,'draw_shadow',p.Results.draw_shadow,'draw_model',p.Results.draw_model,'movname',p.Results.movname,'spitlist',p.Results.spitlist);

if(opt.nlin_regress)
    fixed = [false false false true false];
    [b,r,J,COVB,mse] = nlinfitsome(fixed,x,y,@plane_wave_model,b0);
    ci = nlparci(b(~fixed),r,'jacobian',J);
    ci(5,:) = ci(4,:);
    ci(4,:) = [b0(4),b0(4)];
    r_squared = 1 - sum(r.^2) / sum((y-mean(y)).^2);
else
    b = b0;
    ci = NaN * ones(5, 2);
    r_squared = 1 - sum(r.^2) / sum ((y-mean(y)).^2);
end
    
est = b;