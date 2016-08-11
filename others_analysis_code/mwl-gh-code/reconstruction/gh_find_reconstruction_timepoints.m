function [ok_inds,times] = gh_find_reconstruction_timepoints(...
    r_pos_array,varargin)

% GH_FIND_RECONSTRUCTION_TIMEPOINTS searches r_pos_array for timepoints
%  that cross some criteria (e.g. reconstruction quality, theta power, MUA
%  spike rate, replay line score, running speed)
%
% Return type is [inds,times] a vector of indeces into the reconstruction
%  pdf and the corresponding times.
%
% Implement checklist:
%  - this timebin's reconstruction entropy (*)
%  - this and neighbors' entropy           (*)
%  - this timewin's reconstruction CI      (*)
%  - this and neighbor confidence interval ( )
%  - theta power                           (*)
%  - MUA spike rate                        (*)
%  - replay line score                     ( )
%  - running speed                         (*)
%  - allowable rat position on track       ( )
%  - allowable reconst. position on track  ( )
%  - theta phaze                           ( )

p = inputParser();
p.addParamValue('eeg_r',[],@(x) and(isstruct(x), isfield(x,'raw')));
p.addParamValue('eeg_min_env',0.2);
p.addParamValue('eeg_field','env'); % 'env' usually means 'theta_env
p.addParamValue('eeg_chans',[]); % pass [] to average them all
p.addParamValue('mua_r',[]); % how to test for valid mua_r?
p.addParamValue('mua_field','raw');
p.addParamValue('mua_min_rate',[]);
p.addParamValue('mua_chans',[]);
p.addParamValue('replay_r',[]);
p.addParamValue('min_line_score',[]);
p.addParamValue('pos_info',[],@(x) and(isstruct(x),isfield(x,'lin_cdat')));
p.addParamValue('pdf_entropy',[]);
p.addParamValue('max_present_pdf_entropy',[]);
p.addParamValue('max_recent_pdf_entropy',[]);
p.addParamValue('entropy_conv_sd_secs',0.01);
p.addParamValue('max_reconstruction_ci_width',[]);
p.addParamValue('reconstruction_ci_p_limit', 0.95);
p.addParamValue('recent_pdf_entropy_smooth_window',0.1);
p.addParamValue('min_running_speed',[]);
p.addParamValue('running_direction','bidirect', @(x) max(strcmp(x,...
                                     {'inbound','outbound','bidirect'})));

p.addParamValue('allowable_track_position',[]);                                 
p.addParamValue('allowable_reconstruction_position',[]);
% too much of a fringe feature, to allow passing of a separate r_pos here
%p.addParamValue('r_pos_for_allowable_reconstruction_position',[]);

p.addParamValue('oscillation_phase',[]);
p.addParamValue('oscillation_phase_source','eeg');
% 'phase' usually means theta phase.  sub with 'gamma_phase' for example,
% if you want to trigger on gamma phases
p.addParamValue('oscillation_phase_field','phase'); 
p.addParamValue('oscillation_phase_chan',1, @(x) numel(x) == 1);

p.parse(varargin{:});
opt = p.Results;

ts = linspace(r_pos_array(1).tstart, r_pos_array(1).tend,...
    size(r_pos_array(1).pdf_by_t,2));
dt = ts(2) - ts(1);
inds = 1:numel(ts);
n_inds = numel(ts);
ok_inds = ones(1,n_inds);

% Filter by posterior entropy
if(max([~isempty(opt.pdf_entropy), ...
        ~isempty(opt.max_present_pdf_entropy), ...
        ~isempty(opt.max_recent_pdf_entropy)]))
    if(isempty(opt.pdf_entropy))
        opt.pdf_entropy = reconstruction_entropy(r_pos_array);
    end
    
    % filter on present entropy if we need to (recent  given, or neither
    % given)
    if(or(~isempty(opt.max_present_pdf_entropy),...
            and(isempty(opt.max_present_pdf_entropy),...
                isempty(opt.max_recent_pdf_entropy) )))
        if(isempty(opt.max_present_pdf_entropy))
            opt.max_present_pdf_entropy = 3.0; % <-- default value
        end
        ok_inds = [ok_inds; ...
                   mean(opt.pdf_entropy,1) <= opt.max_present_pdf_entropy];
    end
    
    % filter on local pdf entropy if we need to
    if(~isempty(opt.max_recent_pdf_entropy))
        conv_limit_sd = 4;
        % round entrop_conv_sd_secs to the nearest dt
        opt.entropy_conv_sd_secs = dt * floor(opt.entropy_conv_sd_secs / dt);
        conv_limit_secs = conv_limit_sd * opt.entropy_conv_sd_secs;
        conv_secs = [-conv_limit_secs : dt : conv_limit_secs ];
        conv_kernel = exp(-1.*(conv_secs.^2)./(2 * opt.entropy_conv_sd_secs^2));
        conv_kernel = conv_kernel ./ sum(conv_kernel); % kernel must sum to 1
        smooth_entropy = conv(mean(opt.pdf_entropy,1), conv_kernel, 'same');
        plot(ts,smooth_entropy,'g');
        ok_inds = [ok_inds; ...
                   smooth_entropy <= opt.max_recent_pdf_entropy];
        figure; plot(conv_secs,conv_kernel);
    end
end

%
if(~isempty(opt.max_reconstruction_ci_width))
    ci = reconstruction_ci(r_pos_array, 'bounds', opt.reconstruction_ci_p_limit);
    ci_mean = mean(ci,3);
    mean_ci_width = diff(ci_mean,1);
    ok_inds = [ok_inds; ...
               mean_ci_width <= opt.max_reconstruction_ci_width];
end

% filter on an eeg field (usually envelope)
if(~isempty(opt.eeg_r))
    if(isempty(opt.eeg_chans))
        opt.eeg_chans = 1:size(opt.eeg_r.raw.data,2);
    end
    eeg_ts = conttimestamp(opt.eeg_r.raw);
    r_ts = ts;
    vals_at_r_ts = interp1(eeg_ts, ...
                           mean(opt.eeg_r.(opt.eeg_field).data(:,opt.eeg_chans),2),...
                           r_ts,...
                           'linear','extrap');
    vals_at_r_ts(or(r_ts < min(eeg_ts), r_ts > max(eeg_ts))) = 0;
    ok_inds = [ok_inds; vals_at_r_ts >= opt.eeg_min_env];
end

% filter for mua rate
if and((~isempty(opt.mua_r)),~isempty(opt.mua_min_rate) )
    if(isempty(opt.mua_chans))
        opt.mua_chans = 1:size(opt.mua_r.raw.data,2);
    end
    mua_ts = conttimestamp(opt.mua_r.raw);
    r_ts = ts;
    vals_at_r_ts = interp1(mua_ts, ...
                           mean(opt.mua_r.(opt.mua_field).data(:,opt.mua_chans),2),...
                           r_ts, 'linear','extrap');
    vals_at_r_ts(or(r_ts < min(mua_ts), r_ts > max(mua_ts))) = 0;
    ok_inds = [ok_inds; vals_at_r_ts >= opt.mua_min_rate];
end

% filter on running speed
if(~isempty(opt.min_running_speed))
    run_ts = conttimestamp(opt.pos_info.lin_vel_cdat);
    run_v  = reshape(opt.pos_info.lin_vel_cdat.data, 1, []);
    r_ts = ts;
    v_at_r_ts = interp1(run_ts, run_v, r_ts, 'linear', 'extrap');
    v_at_r_ts(or(r_ts < min(run_ts), r_ts > max(run_ts))) = 0;
    this_ok = abs(v_at_r_ts) >= abs(opt.min_running_speed);
    
    if(strcmp(opt.running_direction,'outbound'))
        this_ok(v_at_r_ts < 0) = false;
    elseif(strcmp(opt.running_direction,'inbound'))
        this_ok(v_at_r_ts > 0) = false;
    end
    
    ok_inds = [ok_inds; this_ok];
end

% filter on track position
if(~isempty(opt.allowable_track_position))
    r_ts = ts;
    pos_ts = conttimestamp(opt.pos_info.lin_filt);
    pos =    (opt.pos_info.lin_filt.data)';
    pos_at_r_ts = interp1(pos_ts, pos, r_ts, 'linear', 'extrap');
    this_ok = and(pos_at_r_ts >= min(opt.allowable_track_position),...
                  pos_at_r_ts <= max(opt.allowable_track_position));
    this_ok(or(r_ts < min(pos_ts), r_ts > max(pos_ts))) = false;
    ok_inds = [ok_inds; this_ok];
end

% filter on reconstruction position
if(~isempty(opt.allowable_reconstruction_position))
    
    % decided against allowing filtering by a different r_pos
    % for now, just use the r_pos we're given.
    %if(isempty(opt.r_pos_for_allowable_reconstruction_position))
    %    allow_r_pos = r_pos_array;
    %else
    %   allow_r_pos = opt.r_pos_for_allowable_reconstruction_position;
    %end
    %r_ts = ts;
    %ar_ts = linspace(allow_r_pos(1).tstart, allow_r_pos(1).tend, ...
    %    size(allow_r_pos(1).pdf_by_t, 2));
    
    r_modes = reconstruction_pos_at_mode(r_pos_array);
    meets_low = min(r_modes,[],1) >= min(opt.allowable_reconstruction_position);
    meets_high= max(r_modes,[],1) <= max(opt.allowable_reconstruction_position);
    ok_inds = [ok_inds; and(meets_low, meets_high)];
end

% filter on phases if necessary (one timepoint per cycle)
if(~isempty(opt.oscillation_phase))
    r_ts = ts;
    if(strcmp(opt.oscillation_phase_source,'mua'))
        phase_source = opt.mua_r;
    elseif(strcmp(opt.oscillation_phase_source,'eeg'))
        phase_source = opt.eeg_r;
    else
        error('gh_find_reconstruction_timepoints:unknown phase source',...
              ['Received unuseable oscillation_phase_source parameter: ',...
              opt.oscillation_phase_source]);
    end
    cdat_ts = conttimestamp(phase_source.(opt.oscillation_phase_field));
    phase_data = mean(phase_source.(opt.oscillation_phase_field).data(:,opt.oscillation_phase_chan),2);
    phase_data = reshape(phase_data,1,[]);
    u_phase_at_r_ts = interp1(cdat_ts, unwrap(phase_data), r_ts,'linear','extrap');
    % re-wrap the unwrapped interpolated data assuming the range is [-pi,pi]
    phase_at_r_ts = mod(u_phase_at_r_ts + pi, 2*pi) - pi;
    % ok if sought-after phase is later than current interp phase and
    % earlier than next interp phase
    ok_1 = and(phase_at_r_ts(1:(end-1)) <= opt.oscillation_phase, ...
               phase_at_r_ts(2:  end  ) >  opt.oscillation_phase);
    % ok if sought-after phase is (greater than current or less than next) phase 
    % and current phase is the local maximum before a reset back to -pi
    ok_2 = and(phase_at_r_ts(1:(end-1)) > (phase_at_r_ts(2:end)+pi/8),...
               or(phase_at_r_ts(1:(end-1)) <  opt.oscillation_phase,...
                  phase_at_r_ts(2:end    ) >= opt.oscillation_phase));
    % ok1 and ok2 each sufficient to accept current point.  each is short of
    % numel(r_ts) by 1, so extend end by one false.
    ok_inds = [ok_inds; [or(ok_1,ok_2),false]];
end

ok_inds = logical(min(ok_inds,[],1));
times = ts(ok_inds);