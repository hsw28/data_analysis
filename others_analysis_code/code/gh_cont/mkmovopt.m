function movopt = mkmovopt(varargin)
% MKMOVOPT makes movie options
% cdat : continuous data structure of td_cont ilk...
%    need not be specified here if bouts are specified
% movtype: {'cont_td'}, 'eeg_3d'
% bouts ([cdat.tstart cdat.tend]): n x 2 array of start, stop times for movie
% boutsindex (all): list of indices of bouts to use for movie
% padding (0): seconds added before and after each bout...
%    in case, eg bouts are from ripple boundaries
% makeavi (true): boolean generate avi
% framerate (15) : movie framerate
% timecompression (1) : fractionaly change the time rate of the signal
%    0.5 corresponds to half original speed; 2 means twice the original
% userdata : currently only supported for eeg_3d (make field 'trodexy')

p = inputParser; 

p.addOptional('cdat',[],@isstruct);
p.addOptional('movtype','cont_td',@(x)any(strcmp(x,...
    {'cont_td','theta_3d','theta_polar','ripp_3d','theta_env'})));
p.addOptional('bouts',[],...
    @(x)(size(x,2)==2));
p.addOptional('boutsindex',[],@(x)all(x>0));
p.addParamValue('padding',0,@(x)x>=0);
p.addParamValue('makeavi',false, @islogical);
p.addParamValue('concatavi',false, @islogical);
p.addParamValue('framerate',15,@(x)x>0);
p.addParamValue('timecompression',1,@(x)(x~=0));
p.addOptional('contopt',[],@isstruct);
p.addOptional('contdrawopt',[],@isstruct);
p.addOptional('userdata',[],@isstruct);
p.addOptional('rat_conv_table',[],@isstruct);
p.addOptional('ripp_sd',0.002, @isreal);
p.addOptional('mua',[],@isstruct);
p.addOptional('filt_pad',5, @isreal);

p.parse(varargin{:});

movopt.cdat = p.Results.cdat;
movopt.movtype = p.Results.movtype;
movopt.bouts = p.Results.bouts;
movopt.boutsindex = p.Results.boutsindex;
if (isempty(movopt.boutsindex))
    movopt.boutsindex = [1:size(movopt.bouts,1)];
end
movopt.padding = p.Results.padding;
movopt.makeavi = p.Results.makeavi;
movopt.concatavi = p.Results.concatavi;
movopt.framerate = p.Results.framerate;
movopt.timecompression = p.Results.timecompression;
movopt.contopt = p.Results.contopt;
movopt.contdrawopt = p.Results.contdrawopt;
movopt.userdata = p.Results.userdata;
movopt.rat_conv_table = p.Results.rat_conv_table;
movopt.ripp_sd = p.Results.ripp_sd;
movopt.mua = p.Results.mua;

range_start = min(min(movopt.bouts)) - p.Results.filt_pad;
range_end = max(max(movopt.bouts)) + p.Results.filt_pad;
win = [range_start + p.Results.filt_pad, range_end - p.Results.filt_pad]; % another temporary fix
% try taking off the +- buffer and looking at the filtered signal
% for some reason it cuts to 0 one second before the end of the time range

movopt.this_cdat = contwin(movopt.cdat, [range_start,range_end]);
samplerate = movopt.this_cdat.samplerate;
samps_per_frame_pre = samplerate / movopt.framerate;
samps_per_frame = samps_per_frame_pre * movopt.timecompression;

% figure out the up/downsampling ratio to make each data sample line up
% with each frame (ie - sample at framerate / compression factor)
upsample_ratio = (movopt.framerate / (samplerate * movopt.timecompression))

if(upsample_ratio > 1)
    disp('Warning: data sample rate lower than display rate.  Upsampling...');
end

movopt.this_cdat.data = double(movopt.this_cdat.data);
movopt.cdat_frames = contresamp(movopt.this_cdat,'resample',upsample_ratio);

if(not(isempty(movopt.rat_conv_table)))
    movopt.userdata.trode_xy = mk_trodexy(movopt.this_cdat,movopt.rat_conv_table);
    movopt.userdata.trode_st_dp = mk_trode_st_dp(movopt.this_cdat,movopt.rat_conv_table);
end

if(any(strcmp(movopt.movtype,{'theta_3d','theta_polar','theta_env'})))
    theta_fo = filtoptdefs();
    theta_fo = theta_fo.theta;
    theta_fo.Fs = movopt.cdat_frames.samplerate;
    theta_fo.F = theta_fo.F;
    theta_filt = mkfilt('filtopt',theta_fo);
    movopt.theta_frames = contfilt(movopt.cdat_frames,'filt',theta_filt,'autoresample',false);
    movopt.phase_frames = multicontphase(movopt.theta_frames);
    %figure; gh_plot_cont(movopt.theta_frames,'spacing',0.5);
    hold on;
    %gh_plot_cont(movopt.cdat_frames,'spacing',0.5);
    %figure; gh_plot_cont(movopt.phase_frames);
    movopt.env_frames = multicontenv(movopt.theta_frames);
    
    movopt.cdat_frames = contwin(movopt.cdat_frames,win);
    movopt.theta_frames = contwin(movopt.theta_frames,win);
    movopt.phase_frames = contwin(movopt.phase_frames,win);
    movopt.env_frames = contwin(movopt.env_frames,win);
    movopt.theta_frames.chanlabels = movopt.cdat.chanlabels;
    movopt.cdat_frames.chanlabels = movopt.cdat.chanlabels;
    movopt.phase_frames.chanlabels = movopt.cdat.chanlabels;
    movopt.env_frames.chanlabels = movopt.cdat.chanlabels;
end



if(strcmp(movopt.movtype, 'ripp_3d'))
    ripp_fo = filtoptdefs();
    ripp_fo = ripp_fo.ripple;
    ripp_fo.Fs = movopt.cdat_frames.samplerate;
    ripp_filt = mkfilt('filtopt',ripp_fo);
    movopt.ripp_frames = contfilt(movopt.cdat_frames,'filt',ripp_filt);
    movopt.ripp_frames.chanlabels = movopt.cdat_frames.chanlabels;
    movopt.ripp_frames = contwin(movopt.ripp_frames,win);
    movopt.ripp_env = multicontenv(movopt.ripp_frames);
    movopt.ripp_phase = multicontphase(movopt.ripp_frames);
    movopt.ripp_env.chanlabels = movopt.cdat_frames.chanlabels;
    movopt.ripp_phase.chanlabels = movopt.cdat_frames.chanlabels;
    if(not(isempty(movopt.mua)))
        ts = conttimestamp(movopt.ripp_frames);
        rates = zeros(size(movopt.ripp_frames,2),size(ts,1));
        for n = 1:size(movopt.ripp_frames.data,2)
            stimes = movopt.mua.clust{n};
            ts_big = repmat(ts,numel(stimes),1);
            stimes = repmat(stimes',1,numel(ts));
            rates(n,:) = sum (1/(movopt.ripp_sd * sqrt(2*pi))...
                .* exp (-1*((stimes-ts_big).^2)./(2*movopt.ripp_sd^2)),1);
        end
    end
    
end


movopt.this_cdat = contwin(movopt.this_cdat,win);


