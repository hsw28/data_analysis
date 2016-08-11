function [t,x,y,ang,heading,validity,xfront,yfront,xback,yback,xvel,yvel] = clean_raw_pos(p_file,varargin)

p = inputParser();
p.addParamValue('timewin',[]);
p.addParamValue('drop_zero', true);
p.addParamValue('drop_neg',true);
p.addParamValue('max_step_px', 5);
p.addParamValue('max_interp_width', 0.5);
p.addParamValue('t_smooth',0.2);
p.addParamValue('xCleanMax',500);
p.addParamValue('yCleanMax',500);
p.parse(varargin{:});
opt = p.Results;

fid = mwlopen(p_file);

cmp = @(x) 1;
if(opt.drop_zero)
    cmp = @(x) x > 0;
end
if(opt.drop_neg)
    % Add (gt 0) requirement
    cmp = @(x) (cmp(x) & x >= 0);
end

ok_frame = (cmp(fid.xfront) & cmp(fid.xback) & ...
        cmp(fid.yfront) & cmp(fid.yback));

ok_clean = fid.xfront <= opt.xCleanMax & fid.xback <= opt.xCleanMax & ...
    fid.yfront <= opt.yCleanMax & fid.yback <= opt.yCleanMax;

ok_frame = ok_frame & ok_clean;

if(~isempty(opt.timewin))
    ts_tmp = fid.timestamp / 10000;
    ok_time = ...
        (ts_tmp >= min(opt.timewin) & ...
        ts_tmp <= max(opt.timewin));
else
    ok_time = ones(size(fid.timestamp));
end
ok_frame = logical(ok_frame);
ok_time = logical(ok_time);

ok = logical(ok_frame & ok_time);

f_ts = double(fid.timestamp) ./ 10000;
f_xf = reshape(double(fid.xfront),1,[]);
f_yf = reshape(double(fid.yfront),1,[]);
f_xb = reshape(double(fid.xback),1, []);
f_yb = reshape(double(fid.yback),1, []);


t = double(f_ts(ok_time));
dt = double(mean(diff(t)));

t =   min(t) : dt : max(t);

n_smooth = floor(opt.t_smooth ./ dt);
if(~mod(n_smooth,2))
    n_smooth = n_smooth + 1;
end

validity = ok(ok_time);


if(~ok(end))
    last_ok = find(ok,1,'last');
    ok(end) = 1;
    f_xf(end) = f_xf(last_ok);
    f_yf(end) = f_yf(last_ok);
    f_xb(end) = f_xb(last_ok);
    f_yb(end) = f_yb(last_ok);
end

f_xf(~ok_time) = 0;
f_yf(~ok_time) = 0;
f_xb(~ok_time) = 0;
f_yb(~ok_time) = 0;

interp_and_smooth = ...
    @(x) reshape( ...
    smooth(interp1(f_ts(ok), x(ok), t,'linear','extrap'),n_smooth), 1, []);

xfront = interp_and_smooth(f_xf);
yfront = interp_and_smooth(f_yf);
xback  = interp_and_smooth(f_xb);
yback  = interp_and_smooth(f_yb);

x = mean([xfront; xback]);
y = mean([yfront; yback]);

ang = atan2( yfront-yback, xfront-xback );

xvel = [0, diff(x)] ./ dt;
yvel = [0, diff(y)] ./ dt;

heading = atan2( yvel, xvel );

