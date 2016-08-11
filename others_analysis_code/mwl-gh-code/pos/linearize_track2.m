function [pos_info, track_info, timewin, click_points] = linearize_track2(p_file,varargin)

% linearize_track looks into p_file
% New features to implement: multiple splines; user-defined zones; lap
% labels assigned by zone sequence
% returns [pos_info, track_info, timewin, click_points]

p = inputParser;
p.addParamValue('reverse_front_back',false,@islogical);
p.addParamValue('timewin',[],@isreal); % use points in this timewindow
p.addParamValue('head_pos_rule','center',@(x) any(strcmp(x,{'front','back','center'})));
p.addParamValue('linearize_rule','delaunay',@(x) any(strcmp(x,{'delaunay','segments'})));
p.addParamValue('head_angle_offset',0,@isreal);
p.addParamValue('filtopt',struct(),@isstruct);
p.addParamValue('max_frame_jump',[],@isreal);
p.addParamValue('track_length',3.59,@isreal);
p.addParamValue('min_interdiode_dist',[],@isreal); % not yet implemented
p.addParamValue('interp_count',500,@isreal); % spline sampling for lin pos
p.addParamValue('nos',20000,@(x)(x>1)); % oversampling for track length calculation
p.addParamValue('timewin_guide',false,@islogical);
p.addParamValue('click_points',[],@isreal);
p.addParamValue('run_thresh',0.15,@isreal); % threshold for 'running' speed.  cm/sec

p.parse(varargin{:});
opt = p.Results;

% gui gives a linearized position back from p_file
% p_file can be a filename or a p2mat struct

if(ischar(p_file))
    p_file = p2mat(p_file);
end

if(opt.reverse_front_back)
    p_file.frame = 1 - p_file.frame;
end

if(opt.timewin_guide)
    opt.timewin = [0,0];
    figure;
    plot(p_file.timestamp,p_file.x,'.');
    hold on
    plot(p_file.timestamp,p_file.y,'g.');
    nframe = numel(p_file.timestamp);
    opt.timewin(1) = input('Run begins at time: ');
    opt.timewin(2) = input('Run ends at time: ');
end

if(not(isempty(opt.timewin)))
    good_index = find(and((p_file.timestamp >= opt.timewin(1)), (p_file.timestamp <= opt.timewin(2))));
    %numel(p_file.timestamp)
    p_file.timestamp = p_file.timestamp(good_index);
    %numel(p_file.timestamp)
    p_file.frame = p_file.frame(good_index);
    p_file.x = p_file.x(good_index);
    p_file.y = p_file.y(good_index);
end



% pairs of frames have the same timestamp.  If one is bad (eg front),
%                   then we also want to call the other bad (eg back)

% ASSUME FOR NOW: Frame0: 'front', pairs always start frame 0


if(isempty(opt.click_points))
    figure;
    plot(p_file.x,p_file.y,'.')
    title('Please click points along track, starting at start, ending at end.  Double-click to set end point.  Thanks');
    %x = linspace(0,opt.track_length,opt.interp_count);
    [xs,ys] = getpts();
    click_points = [xs,ys];
else
    xs = opt.click_points(:,1);
    ys = opt.click_points(:,2);
    click_points = opt.click_points;
end


xx = linspace(0,opt.track_length,opt.interp_count);
x = linspace(0,opt.track_length,numel(xs)); % parameter vals
y = [xs';ys']; % samples of parametric function to be fit by spline
pp = spline(x,y); %#ok<NASGU>
yy = spline(x,y,xx); % make spline description (pp form?)
xx_os = linspace(0,opt.track_length,opt.nos);
yy_os = spline(x,y,xx_os);
%hold on
%plot(yy(1,:),yy(2,:),'g');

% Calculate the track length in ad pos units, via spline fn commands
%dx_dt_sq = fncmb( fndir(pp,[1,0]),'*',fndir(pp,[1,0]));
%dy_dt_sq = fncmb( fndir(pp,[0,1]),'*',fndir(pp,[0,1]));
%sqr_sum = fncmb(  fncmb(dx_dt_sq,'+',dy_dt_sq), 'sqrt');
%track_length = diff(fnval(fnint(sqr_sum),[0,opt.track_length]))
% I thought this would be interesting, but I'm having problems properly
% taking the squar root of the cubic spline function

% Calculate the track length in ad units, via Fabian's oversampling
dx = diff(yy_os(1,:));
dy = diff(yy_os(2,:));
dx_sq = dx .* dx;
dy_sq = dy .* dy;
lengths = (dx_sq + dy_sq).^0.5;
track_length_ad = sum(lengths);



% convert all p_file data into room units (units implicit in user-provided
% track-length)
%user_units_per_ad = opt.track_length / track_length_ad;
%p_file.x = p_file.x .* user_units_per_ad;
%p_file.y = p_file.y .* user_units_per_ad;

pos = p2gpos(p_file,opt);

%figure; plot(pos.timestamp,pos.front_x,'.');hold on; plot(pos.timestamp,pos.front_y,'.')

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
TRI = delaunay(yy(1,:),yy(2,:));
%figure;hist(pos.x);figure;hist(pos.y);
index = dsearch(yy(1,:),yy(2,:),TRI,pos.x,pos.y);
%numel(index)
%figure; hist(index,linspace(min(index),max(index),20));
pos.lin = xx(index)';
figure; plot(pos.timestamp,pos.lin,'.-');

% make a smoothed linear position sdat

lin_cdat = imcont('timestamp',pos.timestamp,'data',pos.lin);
a = filtoptdefs;
a = a.smooth_sd_200ms;
a.Fs = lin_cdat.samplerate;
gauss_filt = mkfilt('filtopt',a);
lin_filt = contfilt(lin_cdat,'filt',gauss_filt);
pos.lin_filt = lin_filt;

% remove points that match both front and back
%keep_ind = [];
%lin_diffs = diff(pos.lin);
%for i = 2:numel(pos.timestamp)-1
%   if not(and((lin_diffs(i-1) == 0),(lin_diffs(i) == 0)))
%       keep_ind = [keep_ind,i];
%   end
%end
%pos.lin_nodouble_timestamp = pos.timestamp(keep_ind);
%pos.lin_nodouble = pos.lin(keep_ind);

% compute linearized speed
size(pos.lin)
size(pos.timestamp)
%speeds = diff(pos.lin_nodouble)./diff(pos.lin_nodouble_timestamp);
%speeds = [speeds;0];

speeds = lin_filt;
size(speeds.data)
size(conttimestamp(speeds))
speeds.data = [diff(speeds.data)./diff(conttimestamp(speeds))';0];


%pos_info = pos;
%track_info = 1;
%xx = [min(pos.lin_nodouble_timestamp):1/60:max(pos.lin_nodouble_timestamp)];
%x = pos.lin_nodouble_timestamp; % parameter vals
%y = speeds; % samples of parametric function to be fit by spline
%pp = spline(x,y); %#ok<NASGU>
%yy = spline(x,y,xx); % make spline description (pp form?)
%size(xx)
%size(yy)
%xx_os = linspace(0,opt.track_length,opt.nos);
%yy_os = spline(x,y,xx_os);
%figure
%plot(x,y,'b.')
%hold on
%plot(xx,yy,'g')
%speed_cdat = imcont('timestamp',pos.lin_nodouble_timestamp,'data',speeds);
%a = filtoptdefs;
%a = a.smooth_sd_200ms;
%a.Fs = speed_cdat.samplerate;
%gauss_filt = mkfilt('filtopt',a);
%speed_filt = contfilt(speed_cdat,'filt',gauss_filt);
%plot(xx,yy,'b'); hold on
%plot(conttimestamp(speed_filt),speed_filt.data);


track_info = 1;
%xx = [min(pos.timestamp):1/60:max(pos.timestamp)];
%x = pos.timestamp; % parameter vals
%y = speeds; % samples of parametric function to be fit by spline
%pp = spline(x,y); %#ok<NASGU>
%yy = spline(x,y,xx); % make spline description (pp form?)

%figure
%plot(x,y,'b.')
%hold on
%plot(xx,yy,'g')
%%%speed_cdat = imcont('timestamp',pos.timestamp,'data',speeds);
%figure
%plot(conttimestamp(speed_cdat),speed_cdat.data);
%title('cdat data')
%%%a = filtoptdefs;
%%%a = a.smooth_sd_400ms;
%%%a.Fs = speed_cdat.samplerate;
%%%gauss_filt = mkfilt('filtopt',a);
%%%speed_filt = contfilt(speed_cdat,'filt',gauss_filt);
%%%pos.speed_filt = speed_filt;
%plot(xx,yy,'b'); 
%title('spline plot')
figure
plot(conttimestamp(speeds),speeds.data);
title('filtered speed')

neg_fn = @(x) (-x);
abs_fn = @(x) abs(x);
pos_speed_filt = speeds;
neg_speed_filt = contfn(speeds,'fn',neg_fn);
abs_speed_filt = contfn(speeds,'fn',abs_fn);

pos.lin_vel_timestamp = conttimestamp(speeds);
pos.lin_vel = speeds.data;
pos.lin_vel_cdat = speeds;

out_run_bouts = contbouts(pos_speed_filt,'datargunits','data',...
    'thresh',opt.run_thresh,'minevdur',0.2,'mindur',0.4,'window',0.1);

in_run_bouts = contbouts(neg_speed_filt,'datargunits','data',...
    'thresh',opt.run_thresh,'minevdur',0.2,'mindur',0.4,'window',0.1);

run_bouts = contbouts(abs_speed_filt,'datargunits','data',...
    'thresh',opt.run_thresh,'minevdur',0.2,'mindur',0.4,'window',0.1);

pos.out_run_bouts = out_run_bouts';
pos.in_run_bouts = in_run_bouts';
pos.run_bouts = run_bouts';

timewin = opt.timewin;
pos.run_thresh = opt.run_thresh;

pos_info = pos;