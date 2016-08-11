function test_find_reconstruction_timepoints(r_pos,pos_info,varargin)
test_current_entropy = false;
test_recent_entropy = false;
test_ci_width = false;
test_eeg_env = false;
test_mua_rate = false;
test_running_speed = false;
test_track_pos = false;
test_reconstruction_pos = false;
test_phase = false;

%%
ts = linspace(r_pos(1).tstart,r_pos(1).tend,size(r_pos(1).pdf_by_t,2));

% Test entropy filter
if(or(test_current_entropy,test_recent_entropy))
e = reconstruction_entropy(r_pos);
ax(1) = subplot(2,1,1);
plot_multi_r_pos(r_pos,pos_info);
ax(2) = subplot(2,1,2);
plot(ts, mean(e,1)); hold on;
linkaxes(ax,'x');
if(test_current_entropy)
[t_inds,tp] = gh_find_reconstruction_timepoints(r_pos,'max_present_pdf_entropy',4.5);
plot(ax(2), tp, zeros(size(tp)),'.');
end
if(test_recent_entropy)
[t_inds,tp] = gh_find_reconstruction_timepoints(r_pos,'max_recent_pdf_entropy',4,'entropy_conv_sd_secs',0.2);
plot(ax(2), tp, ones(size(tp)),'g.');
end
end

%% Test filtering on condfidence interval width
if(test_ci_width)
[t_inds, tp] = gh_find_reconstruction_timepoints(r_pos,...
    'max_reconstruction_ci_width', 0.3);
ci = reconstruction_ci(r_pos);
mean_ci = mean(ci,3);

figure;
ax(1) = subplot(2,1,1); 
plot_multi_r_pos(r_pos,pos_info);
hold on;
plot(ts,mean_ci(1,:),'b.');
plot(ts,mean_ci(2,:),'g.');
ax(2) = subplot(2,1,2);
plot(tp, ones(size(tp)), '.');
ylim([0,2]);
linkaxes(ax,'x');
end

%% Test filtering on theta amplitude
if(test_eeg_env)
if(nargin > 2)
    eeg_r = varargin{1};
    [t_inds, tp] = gh_find_reconstruction_timepoints(r_pos, 'eeg_r',eeg_r,'eeg_min_env',0.1);
    figure;
    gh_plot_cont(eeg_r.theta);
    hold on;
    plot(tp, zeros(size(tp)),'.');
end
end

%% Test filtering on mua rate
if(test_mua_rate)
    if(nargin > 2)
        mua_r = varargin{1};
        [t_inds,tp] = gh_find_reconstruction_timepoints(r_pos,'mua_r',mua_r,'mua_min_rate',500, 'mua_chans',[2 3]);
        figure; gh_plot_cont(mua_r.raw);
        hold on;
        plot(tp, zeros(size(tp)),'.');
    end
end

%% Test on running speed
if(test_running_speed)
    [t_inds,tp] = gh_find_reconstruction_timepoints(r_pos,'pos_info',pos_info,'min_running_speed',0.15,'running_direction','outbound');
    figure; plot(conttimestamp(pos_info.lin_vel_cdat),pos_info.lin_vel_cdat.data);
    hold on;
    plot(tp,  0.3 .* ones(size(tp)),'.');
    plot(tp, -0.3 .* ones(size(tp)),'.');
end

%% Test track position
if(test_track_pos)
    [t_inds,tp] = gh_find_reconstruction_timepoints(r_pos,'pos_info',pos_info,'allowable_track_position',[1 1.5]);
    figure; plot(conttimestamp(pos_info.lin_filt), pos_info.lin_filt.data);
    hold on;
    plot(tp, 0.5.*ones(size(tp)),'.');
    size(tp)
end


%% Test reconstruction position
if(test_reconstruction_pos)
    [t_inds, tp] = gh_find_reconstruction_timepoints(r_pos,'allowable_reconstruction_position',[1 1.5]);
    figure; plot_multi_r_pos(r_pos,pos_info,'norm_c',true); hold on;
    plot(tp, 0.5 .* ones(size(tp)),'.');
    
end

%% Test phase
if(test_phase)
    if(nargin > 2)
        mua_r = varargin{1};
    end
    %oscillation_source = mua_r;
    oscillation_chan =   1;
    oscillation_field = 'phase';
    the_phase = pi/2;
    [t_inds, tp] = gh_find_reconstruction_timepoints(r_pos,'mua_r',mua_r,'oscillation_phase',the_phase,'oscillation_phase_chan',oscillation_chan);
    ax(1) = subplot(2,1,1); plot_multi_r_pos(r_pos,pos_info,'norm_c',true); hold on;
    plot(tp, 2.0 .* ones(size(tp)),'.');
    ax(2) = subplot(2,1,2);
    plot( conttimestamp(mua_r.(oscillation_field)), mua_r.(oscillation_field).data(:,oscillation_chan));
    hold on;
    plot( tp, the_phase .* ones(size(tp)), 'g.');
    linkaxes(ax,'x');
end

if(all([~test_current_entropy, ~test_recent_entropy, ~test_ci_width, ...
        ~test_eeg_env, ~test_mua_rate, ~test_running_speed, ...
        ~test_track_pos, ~test_reconstruction_pos, ~test_phase]))
   [~, tp] = gh_find_reconstruction_timepoints(r_pos,varargin{:});
   plot_multi_r_pos(r_pos,pos_info,'norm_c',true);
   hold on;
   plot( tp, zeros(size(tp)), 'g.');
    
end