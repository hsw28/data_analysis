function [pos_info, track_info, linearize_opts] = linearize_track(p_file,varargin)

% linearize_track looks into [comp].p
% returns [pos_info, track_info, timewin, click_points]

p = inputParser;
p.addParamValue('reverse_front_back',false,@islogical);
p.addParamValue('timewin',[],@isreal); % use points in this timewindow
p.addParamValue('head_pos_rule','center',@(x) any(strcmp(x,{'front','back','center'})));
p.addParamValue('linearize_rule','delaunay',@(x) any(strcmp(x,{'delaunay','segments'})));
p.addParamValue('head_angle_offset',0,@isreal);
p.addParamValue('filtopt',struct(),@isstruct);
p.addParamValue('max_frame_jump',0.25,@isreal);
p.addParamValue('n_clip_jump_iter',50);
p.addParamValue('track_length',3.59,@isreal);
p.addParamValue('min_interdiode_dist',[],@isreal); % not yet implemented
p.addParamValue('interp_count',500,@isreal); % spline sampling for lin pos
p.addParamValue('nos',20000,@(x)(x>1)); % oversampling for track length calculation
p.addParamValue('timewin_guide',false,@islogical);
p.addParamValue('click_points',[],@isreal);
p.addParamValue('circular_track',false);
p.addParamValue('break_angle',[]);
p.addParamValue('run_thresh',0.15,@isreal); % threshold for 'running' speed.  cm/sec
p.addParamValue('calibrate_length',1);
p.addParamValue('calibrate_points',[]);
p.addParamValue('debug_spline',false);
p.addParamValue('xCleanMax',500);
p.addParamValue('yCleanMax',500);
p.addParamValue('linearize_opts',[]);
p.addParamValue('draw',[]);

p.parse(varargin{:});
if(isempty(p.Results.linearize_opts))
    opt = p.Results;
else
    opt = p.Results.linearize_opts;
end
linearize_opts = p.Results;

% gui gives a linearized position back from p_file
% p_file can be a filename or a p2mat struct

% % % if(ischar(p_file))
% % %     p_file = mwlopen(p_file);
% % %     %%%p_file_frame = p_file.frame;
% % % end
% % % 
% % % if(opt.reverse_front_back)
% % %     %%%p_file_frame = 1 - p_file.frame;
% % % end

[t,x,y,ang,heading,validity] = clean_raw_pos(p_file);

if(opt.timewin_guide)
    opt.timewin = [0,0];
    figure;
    plot(t,x,'.');
    hold on
    plot(t,y,'g.');
    nframe = numel(t);
    opt.timewin(1) = input('Run begins at time: ');
    opt.timewin(2) = input('Run ends at time: ');
    [t,x,y,ang,heading,validity] = clean_raw_pos(p_file,'timewin',opt.timewin);
end

if(not(isempty(opt.timewin)))
    good_index = find(and((t >= opt.timewin(1)), (t <= opt.timewin(2))));
    %numel(p_file.timestamp)
    %p_file_timestamp = p_file.timestamp(good_index);
    %numel(p_file.timestamp)
    %%%p_file_frame = p_file_frame(good_index);
    p_file_x = x;
    p_file_y = y;
    [t,x,y,ang,heading,validity] = clean_raw_pos(p_file,'timewin',opt.timewin);
end



% pairs of frames have the same timestamp.  If one is bad (eg front),
%                   then we also want to call the other bad (eg back)

% ASSUME FOR NOW: Frame0: 'front', pairs always start frame 0

x(x > opt.xCleanMax) = 0;
y(y > opt.yCleanMax) = 0;

if(~isempty(opt.calibrate_length))
    if(isempty(opt.calibrate_points))
        figure;
        plot(x,y,'.');
        title(['Please click the start, and double-click the end, of an interval of ',num2str(opt.calibrate_length),' meters']);
        [xs,ys] = getpts();
        opt.calibrate_points = [reshape(xs,1,[]); reshape(ys,1,[])];
        linearize_opts.calibrate_points = [reshape(xs,1,[]); reshape(ys,1,[])];
    else
        xs = opt.calibrate_points(1,:);
        ys = opt.calibrate_points(2,:);
    end
    ad_units_per_meter = sqrt(diff(xs).^2 + diff(ys).^2) ./ opt.calibrate_length;
    opt.m_per_px = 1/ad_units_per_meter;
    linearize_opts = opt;
else
    ad_units_per_meter = 1;
end

if(isempty(opt.click_points))
    figure;
    plot(x,y,'.')
    title('Please click points along track. Double-click to set end point.');
    %x = linspace(0,opt.track_length,opt.interp_count);
    [xs,ys] = getpts();
    click_points = [xs,ys];
    if(~isempty(opt.calibrate_length))
        xs = xs ./ ad_units_per_meter;
        ys = ys ./ ad_units_per_meter;
    end
    linearize_opts.click_points = click_points;
else
    xs = opt.click_points(:,1);
    ys = opt.click_points(:,2);
    click_points = opt.click_points;
    linearize_opts.click_points = opt.click_points;
    if(~isempty(opt.calibrate_length))
        xs = xs./ad_units_per_meter;
        ys = ys./ad_units_per_meter;
    end
end


xx = linspace(0,opt.track_length,opt.interp_count);
x = linspace(0,opt.track_length,numel(xs)); % parameter vals
y = [xs';ys']; % samples of parametric function to be fit by spline
pp = spline(x,y); %#ok<NASGU>
yy = spline(x,y,xx); % make spline description (pp form?)
xx_os = linspace(0,opt.track_length,opt.nos);
yy_os = spline(x,y,xx_os);

yy_next = yy(:,2:end);
yy_this = yy(:,1:end-1);
yy_dists = sqrt((yy_next(2,:)-yy_this(2,:)).^2 + (yy_next(1,:)-yy_this(1,:)).^2);
yy_cum_dists = [0,cumsum(yy_dists)];
max(yy_cum_dists)



new_xx = xx.*max(yy_cum_dists)./max(xx);
new_yy = [interp1(yy_cum_dists,yy(1,:),new_xx);...
    interp1(yy_cum_dists,yy(2,:),new_xx)];

if(opt.debug_spline)
    figure;
    plot(yy(1,:),yy(2,:),'.','MarkerSize',1);
    hold on
    plot(new_yy(1,:),new_yy(2,:),'go');
end

yy = new_yy;

indOk = sum(isnan(yy)) == 0 & isnan(xx) == 0;
xx = xx(:,indOk);
yy = yy(:,indOk);
new_xx = new_xx(:,indOk);
new_yy = new_yy(:,indOk);

track_info.xx_os = new_xx .* opt.track_length ./ max(yy_cum_dists);
track_info.yy_os = new_yy;



% Calculate the track length in ad units, via Fabian's oversampling
dx = diff(yy_os(1,:));
dy = diff(yy_os(2,:));
dx_sq = dx .* dx;
dy_sq = dy .* dy;
lengths = (dx_sq + dy_sq).^0.5;
track_length_ad = sum(lengths);

%new_xx_small = linspace(0, track_length_ad, 

% p2gpos kind of replaced by clean_raw_pos
% pos = p2gpos(p_file,opt);
[t,x,y,ang,heading,validity,xf,yf,xb,yb] = clean_raw_pos(p_file,'timewin',opt.timewin);
pos.timestamp = t;
pos.x = x;
pos.y = y;
pos.front_x = xf;
pos.front_y = yf;
pos.back_x =  xb;
pos.back_y =  yb;


% collapse separated front/back indices into 1-to-1 timestamp-to-pos array
npos = numel(pos.timestamp);
pos.x = NaN.*zeros(size(pos.timestamp));
pos.y = NaN.*zeros(size(pos.timestamp));
pos.diode_angle = NaN.*zeros(size(pos.timestamp)); % head angle inferred from diodes, corrected by opt.head_angle_offset
pos.motion_angle = NaN.*zeros(size(pos.timestamp)); % head angle inferred from animal motion
pos.speed = NaN.*zeros(size(pos.timestamp)); % sqrt(x_vel^2 + y_vel^2)
pos.vel_x = NaN.*zeros(size(pos.timestamp)); % x velocity
pos.vel_y = NaN.*zeros(size(pos.timestamp)); % y velocity
pos.vel_lin = NaN.*zeros(size(pos.timestamp)); % linearized velocity (linear speed, outbound positive, inbound negative)
pos.off_dist = NaN.*zeros(size(pos.timestamp)); % distance from linearized track
pos.lin = NaN.*zeros(size(pos.timestamp)); % the linearized position

% compute 'real' position via head_pos_rule
if(strcmp(opt.head_pos_rule,'back'))
    pos.x = pos.back_x;
    pos.y = pos.back_y;
end
if(strcmp(opt.head_pos_rule,'center'))
    pos.x = (1/2).*(pos.front_x + pos.back_x);
    pos.y = (1/2).*(pos.front_y + pos.back_y);
    %figure; plot(pos.x,pos.y,'.');
end
if(strcmp(opt.head_pos_rule,'front'))
    pos.x = pos.front_x;
    pos.y = pos.back_y;
end
if(~isempty(opt.calibrate_length))
    pos.x = pos.x ./ ad_units_per_meter;
    pos.y = pos.y ./ ad_units_per_meter;
    if(opt.draw)
    figure;
    plot(pos.x,pos.y);
    end
end
pos.speed = sqrt(diff(pos.x).^2 + diff(pos.y).^2) ./ (pos.timestamp(2) - pos.timestamp(1));

%smooth t, x and y
interp_ts = [opt.timewin(1):1/30:opt.timewin(end)];
interp_x = interp1(pos.timestamp,pos.x,interp_ts);
interp_y = interp1(pos.timestamp,pos.y,interp_ts);
%[interp_ts, interp_x] = gh_interp_pos(pos.timestamp,pos.x);
%[interp_ts, interp_y] = gh_interp_pos(pos.timestamp,pos.y);
size(interp_ts)
size(interp_x)
pos.interp_ts = interp_ts;
pos.interp_x = interp_x;
pos.interp_y = interp_y;
%pos.timestamp = interp_ts;
x_cdat = imcont('timestamp',interp_ts','data',interp_x');
x_cdat.data = double(x_cdat.data);
y_cdat = imcont('timestamp',interp_ts','data',interp_y');
y_cdat.data = double(y_cdat.data);
a = filtoptdefs;
a = a.smooth_sd_5ms;
a.Fs = x_cdat.samplerate;
gauss_filt = mkfilt('filtopt',a);
pos.x_filt = contfilt(x_cdat,'filt',gauss_filt);
pos.y_filt = contfilt(y_cdat,'filt',gauss_filt);
pos.x_cdat = x_cdat;
pos.y_cdat = y_cdat;


%figure; plot(pos.x,pos.y)

% compute diode angle and motion angle
pos.diode_angle = atan((pos.front_y-pos.back_y)./(pos.front_x-pos.back_x)) - opt.head_angle_offset;
%figure; plot(pos.timestamp,pos.diode_angle);
dx = diff(pos.x);
dy = diff(pos.y);
ok_index = find(dx ~= 0);
bad_index = setdiff(1:numel(dx),ok_index);
pos.motion_angle(ok_index+1) = atan(dy(ok_index))./dx(ok_index);
pos.motion_angle(bad_index+1) = pi/2 .* sign(dy(bad_index));
%figure; plot(pos.timestamp,pos.motion_angle);

% compute linearized position
n_lin_p = opt.interp_count;
n_pos_t = numel(pos.timestamp);
% Use delaunay trangulation to get the closest linearized track points
%TRI = delaunay(yy(1,:), yy(2,:)) % <-- No longer works due to removal of dsearch
TRI = DelaunayTri(yy(1,:)',yy(2,:)'); % <-- replacement for the above
%index = dsearch(yy(1,:),yy(2,:),TRI,pos.x_filt.data,pos.y_filt.data);
index = nearestNeighbor(TRI,[pos.x',pos.y']); % <-- replacement for dsearch

pos.lin = xx(index)';

ts_for_interp = pos.timestamp;
if(~opt.circular_track)
    lin_for_interp = pos.lin;
else
    lin_for_interp = unwrap_by(pos.lin, max(pos.lin));
end
for n = 1:opt.n_clip_jump_iter
    ok_bool = abs(diff(lin_for_interp)) < opt.max_frame_jump; % new stuff
    ts_for_interp = ts_for_interp(ok_bool); % new stuff
    lin_for_interp = lin_for_interp(ok_bool); % new stuff
end
if(opt.circular_track)
   lin_for_interp = mod(lin_for_interp,max(pos.lin)); 
end
% make a smoothed linear position sdat

%pos.interp_lin = interp1(pos.timestamp,pos.lin,interp_ts); % removed line
% while trying to cut lin jumps on 06/07/2010
pos.interp_lin = interp1(ts_for_interp,lin_for_interp,interp_ts); % new line
%[pos.interp_ts, pos.interp_lin] = gh_interp_pos(pos.timestamp,pos.lin);
lin_cdat = imcont('timestamp',pos.interp_ts','data',pos.interp_lin');
pos.lin_cdat = lin_cdat;
a = filtoptdefs;
a = a.smooth_sd_1ms;
a.Fs = lin_cdat.samplerate;
gauss_filt = mkfilt('filtopt',a);
%if(~opt.circular_track)
    lin_filt = contfilt(lin_cdat,'filt',gauss_filt);
%else
%    lin_cdat2 = lin_cdat;
%    lit_cdat2.data = unwrap_by(lin_cdat2.data, max(lin_cdat2.data));
%    lin_filt = contfilt(lin_cdat2,'filt',gauss_filt);
%    lin_filt.data = mod(lin_filt.data, max(lin_cdat.data));
%end


%pos.lin_nodouble = pos.lin(keep_ind);

% compute linearized speed
disp(['Size of pos.lin: ', num2str(size(pos.lin))])
disp(['Size of pos.timestamp: ', num2str(size(pos.timestamp))]);
%speeds = diff(pos.lin_nodouble)./diff(pos.lin_nodouble_timestamp);
%speeds = [speeds;0];

speeds = lin_filt;
%size(speeds.data)
%size(conttimestamp(speeds))
%if(~opt.circular_track)
    speeds.data = [diff(speeds.data)./diff(conttimestamp(speeds))';0];
%else
%    dat = unwrap_by( lin_filt.data, max(lin_cdat.data(~isnan(lin_cdat.data))));
%    speeds.data = [diff(dat) ./ diff(conttimestamp(speeds))';0];
%end

if(opt.circular_track)
    lin_filt.data = mod(lin_filt.data, max(pos.lin));
end
pos.lin_filt = lin_filt;

if(opt.draw)
figure;
subplot(3,1,1);
plot(pos.timestamp,pos.lin);
subplot(3,1,2);
plot(conttimestamp(pos.lin_cdat),pos.lin_cdat.data(:,1));
subplot(3,1,3);
plot(conttimestamp(pos.lin_filt),pos.lin_filt.data(:,1));
end

neg_fn = @(x) (-x);
abs_fn = @(x) abs(x);
pos_speed_filt = speeds;
neg_speed_filt = contfn(speeds,'fn',neg_fn);
abs_speed_filt = contfn(speeds,'fn',abs_fn);

pos.lin_vel_timestamp = conttimestamp(speeds);
pos.lin_vel = speeds.data;
pos.lin_vel_cdat = speeds;
pos.lin_vel_cdat.data( abs(pos.lin_vel_cdat.data) > 1 ) = 0;
disp('about to do a smooth, is this the slowe one?')
pos.lin_vel_cdat.data = reshape(smooth(pos.lin_vel_cdat.data',15),[],1);
disp('done with the smooth');

out_run_bouts = contbouts(pos_speed_filt,'datargunits','data',...
    'thresh',opt.run_thresh,'minevdur',0.2,'mindur',0.4,'window',0.1);
out_run_bouts = out_run_bouts';

in_run_bouts = contbouts(neg_speed_filt,'datargunits','data',...
    'thresh',opt.run_thresh,'minevdur',0.2,'mindur',0.4,'window',0.1);
in_run_bouts = in_run_bouts';

run_bouts = contbouts(abs_speed_filt,'datargunits','data',...
    'thresh',opt.run_thresh,'minevdur',0.2,'mindur',0.4,'window',0.1);
run_bouts = run_bouts';

pos.out_run_bouts = out_run_bouts';
pos.in_run_bouts = in_run_bouts';
pos.run_bouts = run_bouts';

timewin = opt.timewin;
pos.run_thresh = opt.run_thresh;

pos_info = pos;