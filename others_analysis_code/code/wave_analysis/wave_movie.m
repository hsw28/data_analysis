function [fig,eeg_r] = wave_movie(eeg_r, rat_conv_table, varargin)

p = inputParser();

p.addParamValue('fig_pos',[1 1100 500 700]);
p.addParamValue('timewin',[eeg_r.raw.tstart,eeg_r.raw.tend]);
p.addParamValue('time_scale',10);
p.addParamValue('frame_rate',20);
p.addParamValue('xlim',[0 7]);
p.addParamValue('ylim',[-7 -1]);
p.addParamValue('zlim',[-0.2 0.2]);
p.addParamValue('clim',[1 200]);
p.addParamValue('slim',[2 200]);
p.addParamValue('s_range',[-0.2 0.2]);
p.addParamValue('color_range',[0 0 1; 1 0 0]);
p.addParamValue('camorbit_period',5);
p.addParamValue('ripple',false,@islogical);

p.addParamValue('movname',[]);

p.addParamValue('dot_z','theta');
p.addParamValue('dot_c','mua');
p.addParamValue('dot_size',10);

p.addParamValue('draw_model',false);
p.addParamValue('model_results',[]);
p.addParamValue('model_fn',@plane_wave_model);
p.addParamValue('model_win_length',0.125);
p.addParamValue('model_params',[]);
p.addParamValue('model_x_range',[0.5 6.5]);
p.addParamValue('model_y_range',[-6.5 -1.5]);
p.addParamValue('model_step',0.1);

p.addParamValue('draw_mua',false);
p.addParamValue('mua_sdat',[]);
p.addParamValue('exp_length',0.005);
p.addParamValue('rect_win_length',[]);
p.addParamValue('spike_width_ok_range',[]);

p.addParamValue('draw_shadow',true);

p.addParamValue('draw_r_pos',false);
p.addParamValue('r_pos',[]);
p.addParamValue('place_cells',[]);
p.addParamValue('pos_info',[]);
p.addParamValue('trode_groups',[]);
p.addParamValue('time_marker_color',[1 0 0]);
p.addParamValue('r_pos_timewin',[]);
p.parse(varargin{:});
opt = p.Results;
if(isempty(opt.r_pos_timewin))
    opt.r_pos_timewin = opt.timewin;
end

% check framerate, re_sample eeg if needed
native_rate = eeg_r.raw.samplerate;
native_framerate = native_rate / opt.time_scale; % time_scale of 10 means 1 real second takes 10 secs to play
framerate = native_framerate;
if(native_framerate > 100)
    warning('wave_movie:too_fast_frame_rate',['Native framerate ', num2str(native_framerate), ...
        ' is too fast for playback. Pass frame_rate param to re-sample the timeseries.']);
end
if(~isempty(opt.frame_rate)) % then mu
    if(opt.frame_rate > framerate)
        warning('wave_movie:framerate_upsample_requested',['Data at ',num2str(native_rate),' samplerate and ',...
            num2str(opt.time_scale),'X slow-down has a native framerate of,' num2str(native_framerate), ...
            '.  Your requested framerate of ', num2str(opt.frame_rate),' requires upsampling.  This is not well tested.']);
    end
    field_names = fieldnames(eeg_r);
    if(~isempty(opt.timewin))
        eeg_r.raw = contwin(eeg_r.raw,opt.timewin + [-4 4]);
    end
    eeg_resamped = contresamp(eeg_r.raw,'resample',opt.frame_rate/framerate);
    eeg_r = prep_eeg_for_regress(eeg_resamped,'timewin_buffer',3,'ripple',opt.ripple);
    %for n = 1:numel(field_names)
    %    eeg_r.(field_names{n}) = contresamp(eeg_r.(field_names{n}),'resample',opt.frame_rate/framerate);
    %end
    framerate = opt.frame_rate;
end

if(~isempty(opt.timewin))
    eeg_r = contwin_r(eeg_r,opt.timewin);
    if(~isempty(opt.mua_sdat))
        opt.mua_sdat = sdatslice(opt.mua_sdat,'timewin',opt.timewin);
    end
end
n_ts = size(eeg_r.env.data,1);
ts = conttimestamp(eeg_r.raw);
n_eeg = size(eeg_r.raw.data,2);

% if needed, add 'mua' field to eeg_r
if(~isempty(opt.mua_sdat))
    eeg_r.mua = eeg_r.raw; % template for rate cdat
    for n = 1:n_eeg
        this_eeg_comp = eeg_r.mua.chanlabels{n};
        mua_ind = [];
            trk = cell(n_eeg);
        for m = 1:numel(opt.mua_sdat.clust)
            if(strcmp(this_eeg_comp,opt.mua_sdat.clust{m}.comp))
                mua_ind = [mua_ind,m];
            end
        end
        if(numel(mua_ind) > 1)
            error('wave_movie:sdat_mua_bad_correspondence',['Found ',num2str(numel(mua_ind)),' matches for comp ', this_eeg_comp]);
        elseif(isempty(mua_ind))
            eeg_r.mua.data(:,n) = zeros(n_ts,1);
        else
            stimes = opt.mua_sdat.clust{mua_ind}.stimes;
            if(~isempty(opt.spike_width_ok_range))
                ok_bool = (opt.mua_sdat.clust{mua_ind}.t_maxwd >= opt.spike_width_ok_range(1) &...
                    opt.mua_sdat.clust{mua_ind}.t_maxwd <= opt.spike_width_ok_range(2));
                stimes = stimes(ok_bool);
            end
            
            n_spikes = numel(stimes);
            %big_spike_times = repmat(reshape(stimes,1,[]),n_ts,1);
            %big_times = repmat(reshape(ts,[],1),1,n_spikes);
            y = zeros(n_ts,1);
            this_eeg_comp
            the_coef = 1/sqrt(2*pi*opt.exp_length);
            for m = 1:n_spikes
            if(isempty(opt.rect_win_length)) % then use the exponential kernel
                lambda = 1/opt.exp_length;
                b =  (ts' > stimes(m)) .* (lambda.*exp(-lambda.*(ts' - stimes(m))));
                b =  the_coef.*exp(- (ts' - stimes(m)).^2 ./ (2*opt.exp_length.^2));
                b(isnan(b)) = 0;
                y = y + b;
                %trk{n} = [trk{n},any(isnan(b))];
                    
                    %error('got some NaN!'
            else % spike causes mua to go high for win_length time after spike
                y = y+  (ts' >= stimes(m)) & ( ts' <= (stimes(m) + opt.rect_window_length));
            end
            end
            eeg_r.mua.data(:,n) = y;
        end     
    end  % build up mua rate timeseries
end

trodexy = mk_trodexy(eeg_r.raw,rat_conv_table);
n_trode = size(trodexy,1);

% init fig
if(opt.draw_r_pos)
    fig = figure('Position',opt.fig_pos);
else
    fig = figure;
end

if(~isempty(opt.movname))
    avifilename = opt.movname;
    aviobj = avifile(avifilename,'FPS',opt.frame_rate);
    set(fig,'DoubleBuffer','on');
end

if(opt.draw_r_pos)
    subplot(2,1,1);
end

h_dots = scatter3(trodexy(:,1),trodexy(:,2),ones(n_trode,1),100,'filled');
ax1 = gca;
hold on;



set(gca,'Projection','perspective');
if(~isempty(p.Results.movname))
    set(gca,'XTickLabel',{});
    set(gca,'YTickLabel',{});
    set(gca,'ZTickLabel',{});
    set(gcf,'Color', [1 1 1]);
    %set(gca,'XTick',[0]);
    %set(gca,'YTick',[0]);
    %set(gca,'ZTick',[0]);
end
    
if(opt.draw_model)
    if(~isempty(opt.model_results))
        model_results = opt.model_results;
    else
        % TODO: call gh_long_wave_regress here
        disp('for now, please call gh_long_wave_regress yourself and pass in beta_data as model_results param');
    end
    x = opt.model_x_range(1):opt.model_step:opt.model_x_range(2);
    y = opt.model_y_range(1):opt.model_step:opt.model_y_range(2);
    [xx,yy] = meshgrid(x,y);
    mesh_x = [ts(1).*ones(numel(xx),1),reshape(xx,[],1),reshape(yy,[],1)];
    zz = opt.model_fn(model_results.est(:,1)',mesh_x);
    zz = reshape(zz,size(xx,1),size(xx,2));
    m_surf = surf(xx,yy,zz);
    colormap jet;
    set(gca,'CLim',opt.clim);
end

if(opt.draw_shadow)
    if(opt.draw_model)
        shadow_x = [ts(1).*ones(size(trodexy(:,1))),trodexy(:,1),trodexy(:,2)];
        shadow_y = opt.model_fn(model_results.est(:,1)',shadow_x);
        s_dots = scatter3(trodexy(:,1),trodexy(:,2),shadow_y,100,'filled'); % NEED TO SET THIS UP
    else % if no model, draw shadows on the floor
        s_dots = scatter3(trodexy(:,1),trodexy(:,2),min(opt.zlim).*ones(n_trode,1),100,'filled');
    end
end

fnames = fields(eeg_r);
    if(~isempty(opt.dot_c))
        if(~any(strcmp(fnames,opt.dot_c)))
            warning('wave_movie:no_matching_field',['Found no field named ', opt.dot_c,' in eeg_r to use as color data. Using 0']);
            eeg_r.(opt.dot_c) = eeg_r.raw;
            eeg_r.(opt.dot_c).data = zeros(size(eeg_r.raw.data));
        end
    else
        c_levels = zeros(1,n_eeg);
    end 

if(opt.draw_r_pos)
    if(isempty(opt.r_pos))
        if(~isempty(opt.trode_groups))
            opt.r_pos = decode_pos_with_trode_pos(opt.place_cells, opt.pos_info,opt.trode_groups, 'r_tau', 0.015,'fraction_overlap',7/8,'r_timewin', opt.r_pos_timewin);
        else
            opt.r_pos = gh_decode_pos(opt.place_cells, opt.pos_info, 'r_tau', 0.015, 'fraction_overlap', 7/8,'r_timewin', opt.r_pos_timewin);
        end
    end
    subplot(2,1,2);
    h_r_pos = plot_r_pos(opt.r_pos,opt.pos_info,'color','blue','white_background',true,'scale_exponent',2/3);
    ax2 = gca;
    hold on;
    xlim(opt.r_pos_timewin);
    h_track = plot([ts(1),ts(1)],opt.r_pos(1).x_range,'--','Color',opt.time_marker_color);
end
    
for n = 1:n_ts
    set(h_dots,'ZData',eeg_r.(opt.dot_z).data(n,:));
    %set(h_dots,'ZData',zeros(1,n_eeg));
    %set(h_dots,'SizeData',(eeg_r.(opt.dot_z).data(n,:)).*diff(opt.slim)./d
    %iff(opt.s_range)+100);
    c_levels = eeg_r.(opt.dot_c).data(n,:);
    c_dat = (c_levels - opt.clim(1)) ./ (diff(opt.clim));
    c_dat = min(c_dat,ones(size(c_dat)));
    c_dat = max(c_dat,zeros(size(c_dat)));
    c_dat = repmat(c_dat',1,3);
    c1 = repmat(opt.color_range(1,:),n_trode,1);
    c2 = repmat(opt.color_range(2,:),n_trode,1);
    c = c_dat.*c2 + (1-c_dat).*(c1);
    set(h_dots,'CData',c);
    if(opt.draw_shadow)
    set(s_dots,'CData',c./2);
    end
    if(opt.draw_model)
           mesh_x(:,1) = repmat(ts(n),size(mesh_x(:,1),1),1);
           shadow_x(:,1) = repmat(ts(n),size(shadow_x(:,1),1),1);
           this_ind = find(ts(n) >= (model_results.start_times - 0.00001),1,'last'); 
           mesh_z = opt.model_fn(model_results.est(:,this_ind)',mesh_x);
           shadow_z = opt.model_fn(model_results.est(:,this_ind)',shadow_x);
           set(m_surf,'ZData',reshape(mesh_z,size(xx,1),size(xx,2)));
           set(s_dots,'ZData',shadow_z);
    end
    
    axes(ax1);
    xlim(opt.xlim);
    ylim(opt.ylim);
    zlim(opt.zlim);
    if(~isempty(opt.camorbit_period))
        axes(ax1);
        camorbit(-(1/opt.camorbit_period)*360/(2*pi) / framerate, 0);
    end
    
    if(opt.draw_r_pos)
        set(h_track,'XData',[ts(n),ts(n)]);
    end
    
    drawnow;
    if(~isempty(p.Results.movname))
           disp('get frame');
           frame = getframe(fig);
           aviobj = addframe(aviobj,frame);
    else
        pause(1/opt.frame_rate);
    end
    title(num2str( round(ts(n) * 100) / 100));
end

if(not(isempty(p.Results.movname)))
    aviobj = close(aviobj);
end