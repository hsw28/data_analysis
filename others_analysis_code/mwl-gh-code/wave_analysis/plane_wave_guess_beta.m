function betahat = plane_wave_guess_beta(eeg,trodexy,varargin)

p = inputParser();
p.addParamValue('x',[]);
p.addParamValue('y',[]);
p.addParamValue('draw_data',false);
p.addParamValue('fps',20);
p.addParamValue('draw_shadow',true);
p.addParamValue('draw_model',true);
p.addParamValue('movname',[]); % give a movename string if you want an avi
p.addParamValue('spitlist',[]);
p.parse(varargin{:});

n_chans = size(eeg.raw.data,2);
n_time = size(eeg.raw.data,1);

sl = p.Results.spitlist; % vector of frames to pull from movie into independent figs

if(any([isempty(p.Results.x),isempty(p.Results.y)]))
    data = eeg.theta.data;
    data = eeg.raw.data;
    n_time = size(eeg.raw.data,1);
    pos = repmat(trodexy,n_time,1);

    time = conttimestamp(eeg.raw);
    time = reshape(time,[],1);
    time = repmat(time,1,n_chans); % for 3 chans: [t1 t1 t1; t2 t2 t2; ...]
    time = reshape(time',[],1); % for 3 chans: [t1; t1; t1; t2; t2; t2; ...]

    x = [time,pos(:,1),pos(:,2)];
    y = reshape(data',[],1);
else
    x = p.Results.x;
    y = p.Results.y;
end

% first calculate mean frequency
cum_phase = unwrap(eeg.phase.data,1); % accumulate phase by unwrapping
rad_per_sec_row = (cum_phase(end,:) - cum_phase(1,:)) ./ (eeg.phase.tend-eeg.phase.tstart); % difference each column and divide by timespan (radians per sec)
freq_row = rad_per_sec_row ./ (2*pi); % 1 cycle per 2pi rad * rad per sec = Hz
freq_avg = mean(freq_row); % Just average freq across all channels for now.

% calculate mean phase by time
instant_global_phase = gh_circular_mean(eeg.phase.data,'dim',2);

% calculate deviations on individual channels by time
phase_offsets_by_time = eeg.phase.data - repmat(instant_global_phase,1,n_chans);
mean_phase_offsets = gh_circular_mean(phase_offsets_by_time,'dim',1);
mean_phase_offsets = mean_phase_offsets'; % want a vertical stack, like trodexy's shape

% add n*(2pi) to try to eliminate jump discontinuities
add_vec = 2*pi.*(mean_phase_offsets < -pi);
sub_vec = -2*pi.*(mean_phase_offsets > pi);
mean_phase_offsets = mean_phase_offsets + add_vec + sub_vec;
% report it if we've done this, b/c I think it shouldn't happen
if(any(or(abs(add_vec),abs(sub_vec))))
    disp('added or subtracted 2*pi');
end

% get the slope of phase offset vs ml (x), and phase offset vs ap (y).
% Infer the direction angle from relative x, y contributions
X = [ones(size(trodexy,1),1), trodexy(:,1), trodexy(:,2)];
this_y = mean_phase_offsets;
b = regress(this_y,X); % try find b(1:3) so that y = b(0) + b(1)*x + b(2)*y
dphase_by_dx = b(2);
dphase_by_dy = i*b(3);
increasing_phase_vec = dphase_by_dx + dphase_by_dy; % radians of oscillation per mm
wave_angle = angle(increasing_phase_vec) + pi; % wave direction argle (radians)
% added pi b/c angle gives increasing slope, but wave model defines theta
% in terms of decreasing phase (arrow start: late phase, arrow end: early
% phase)
wave_length = 2*pi * (1 / abs(increasing_phase_vec)); % mm per radian * radians per cycle = mm per cycle

wave_height = mean(mean(eeg.env.data));

%figure out phase offset by comparing data to a yhat with phase offset = 0
phase_no_phi = plane_wave_model([freq_avg, wave_length, wave_angle, 0, wave_height],x, 'yhat_form','phase');
phase_data = reshape(eeg.phase.data',[],1);
phase_diffs = gh_circular_subtract(phase_data,phase_no_phi);
%hist(phase_diffs);
global_mean_phase_offset = gh_circular_mean(phase_diffs,'dim',1);
%global_mean_phase_offset = mean(mean(eeg.phase.data));


betahat = [freq_avg, wave_length, wave_angle, global_mean_phase_offset, wave_height];

draw_something = any([p.Results.draw_data, p.Results.draw_model, p.Results.draw_shadow]);
if(draw_something)
    
    fg = figure;
    if(~isempty(p.Results.movname))
        avifilename = p.Results.movname;
        aviobj = avifile(avifilename,'FPS',p.Results.fps);
        set(fg,'DoubleBuffer','on');
    end

    if(p.Results.draw_data)
        h_data = plot3(trodexy(:,1),trodexy(:,2),trodexy(:,1)+trodexy(:,2),'bo','MarkerSize',8); %placeholder for real data
        h_data2 = text(trodexy(:,1),trodexy(:,2),zeros(size(trodexy,1),1),eeg.raw.chanlabels);
        hold on;
    end
    if(p.Results.draw_model)
        %setup model predictors similar to input predictors
        xfit = min(x(:,2))-1:0.2:max(x(:,2))+1;
        yfit = min(x(:,3))-1:0.2:max(x(:,3))+1;
        [XFIT,YFIT] = meshgrid(xfit,yfit);
        oldsize = size(XFIT);
        h_mod = mesh(XFIT,YFIT,XFIT.*YFIT); %placeholder for model mesh
        hold on;
    end
    if(p.Results.draw_shadow)
        h_shadow = plot3(trodexy(:,1),trodexy(:,2),trodexy(:,1).*trodexy(:,2),'ko','MarkerSize',6); %placeholder for data shadow on model
        hold on;
    end
    set(gca,'Projection','perspective');
    if(~isempty(p.Results.movname))
        set(gca,'XTickLabel',{});
        set(gca,'YTickLabel',{});
        set(gca,'ZTickLabel',{});
    end
    
    tfit = unique(x(:,1));
    n_t = numel(tfit);
    
    % loop through unique times
    for n = 1:n_t
        
        this_spit = any(n == sl); % is this frame on the spitlist?
        this_t = tfit(n);
        all_t = x(:,1);
        keep_ind = find(this_t == all_t);
        
        if(this_spit)
            c = figure;
        end
        
        % draw the model
        if(p.Results.draw_model)
            this_x = [repmat(this_t,numel(XFIT),1),reshape(XFIT,[],1),reshape(YFIT,[],1)];
            this_y = reshape(plane_wave_model(betahat,this_x), size(XFIT));
            set(h_mod,'zdata',this_y);
            if(this_spit)
                figure(c);
                mesh(XFIT,YFIT,reshape(plane_wave_model(betahat,this_x), size(XFIT)));
                hold on;
                %set(gca,'Projection','perspective');
            end
        end
        
        % draw the shadow
        this_x = x(keep_ind,:);
        this_y = plane_wave_model(betahat,this_x);
        
        if(p.Results.draw_shadow)
            set(h_shadow,'zdata',this_y);
            if(this_spit)
                figure(c);
                plot3(trodexy(:,1),trodexy(:,2),this_y,'ko','MarkerSize',6);
            end
        end
            
        % draw data
        this_x_pos = x(keep_ind,2);
        this_y_pos = x(keep_ind,3);
        %keep_ind
        %size(y)
        this_data = y(keep_ind,1);
        set(h_data,'xdata',this_x_pos);
        set(h_data,'ydata',this_y_pos);
        set(h_data,'zdata',this_data);
        xlim([min(x(:,2))-1 max(x(:,2))+1]);
        ylim([min(x(:,3))-1 max(x(:,3))+1]);
        zlim([-0.3 0.3]);
        if(this_spit)
            figure(c);
            plot3(this_x_pos,this_y_pos,this_data,'bo','MarkerSize',8);
            xlim([min(x(:,2))-1 max(x(:,2))+1]);
            ylim([min(x(:,3))-1 max(x(:,3))+1]);
            zlim([-0.5 0.5]);
            title(num2str(n));
            set(gca,'XTickLabel',{});
            set(gca,'YTickLabel',{});
            set(gca,'ZTickLabel',{});
            set(gca,'XTick',[]);
            set(gca,'YTick',[]);
            set(gca,'ZTick',[]);
        end
            
        
        
        if(not(isempty(p.Results.fps)))
            pause(1/p.Results.fps);
        end
        
        if(~isempty(p.Results.movname))
            disp('get frame');
            frame = getframe(gca);
            aviobj = addframe(aviobj,frame);
        end
    end % end time loop
    
    if(not(isempty(p.Results.movname)))
        aviobj = close(aviobj);
    end
end