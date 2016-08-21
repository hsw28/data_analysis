%% Variables
vel_thold = .1;

%% Load DATA
exp = exp12;
ep = 'saline';

if isfield('position', exp.(ep))
    pos = exp.(ep).position.lin_pos;
    vel = exp.(ep).position.lin_vel;
    pts = exp.(ep).position.timestamp;
else
    pos = exp.(ep).pos.lp;
    vel = exp.(ep).pos.lv;
    pts = exp.(ep).pos.ts;
end

if isnan(pos(1))
    pos(1) = pos(find(~isnan(pos),1,'first'));
end
    
while any(isnan(pos))
    pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
end

%% Load Data Amplitues --------------------------
% clear amps_sqr amps_sqr sqrt_amps amps_m ns method
 amps = load_tetrode_amps(exp,ep);
% amps = select_amps_by_feature(amps,'feature','col','col_num',8,'range',[12 40]);
%%
replay.amps = amps;
%% Decode using both Limited Amplitude Ranges

et = exp.(ep).et;
r1 = [et(1) mean(et)];
r2 = [mean(et) et(2)];

r3 = [3365.4 3378.6];

t_range = r1;
d_range = r3;
%%
dt = [.005 .01 .015 .02 .025 .05 .1];

%%
tic;
for i=1:numel(dt)
    disp(['Decoding: ', num2str(i), ' of: ' , num2str(numel(dt)), ' estimates']);
    [replay.est{i} tbins pbins] = decode_amplitudes(replay.amps, pos', t_range, d_range,...
        'dt', dt(i), 'wb',1,'wb_color', 'y');
    method{i} = [' dt', num2str(dt(i)), ' sec'];
end
t = toc;

disp(['Decoded: ', num2str(diff(d_range)), ' seconds of data ', num2str(numel(est)), ' times in ', num2str(t), ' seconds']);

%%
plot_amp_decoding_estimate_errors(log_est,exp.(ep).pos, 'decode_range', d_range, 'legend', method);
%% Plot the 4 estimates with eachother

figure;
xm = .05;
dx = .925;
ym = .24;
dy = .18;

ax(1) = axes('Position', [xm, ym*3, dx, dy]);
ax(2) = axes('Position', [xm, ym*2, dx, dy]);
ax(3) = axes('Position', [xm, ym*1, dx, dy]);
ax(4) = axes('Position', [xm, ym*0, dx, dy]);

e = replay.est{1};
i = ~logical(nansum(e));
e(:,i) = 1/size(e,1);
ec(:,:,1) = e;
ec(:,:,2) = e;
ec(:,:,3) = e;
ec = 1-ec;
imagesc(ec,'Parent',ax(1));
title(ax(1), '4 Channels');

e = replay.est{2};
i = ~logical(nansum(e));
e(:,i) = 1/size(e,1);
ec(:,:,1) = e;
ec(:,:,2) = e;
ec(:,:,3) = e;
ec = 1-ec;
imagesc(ec,'Parent',ax(2));
title(ax(2), '3 Channels');

e = replay.est{3};
i = ~logical(nansum(e));
e(:,i) = 1/size(e,1);
ec(:,:,1) = e;
ec(:,:,2) = e;
ec(:,:,3) = e;
ec = 1-ec;
imagesc(ec,'Parent',ax(3));
title(ax(3), '2 Channels');

e = replay.est{4};
i = ~logical(nansum(e));
e(:,i) = 1/size(e,1);
ec(:,:,1) = e;
ec(:,:,2) = e;
ec(:,:,3) = e;
ec = 1-ec;
imagesc(ec,'Parent',ax(4));
title(ax(4), '1 Channel');

%inkaxes(ax,'x');
