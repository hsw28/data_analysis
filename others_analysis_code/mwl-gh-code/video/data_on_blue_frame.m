function fr_out = data_on_blue_frame(fr_in, i, eeg, mua, opt)

hold off;
fr_out = image(opt.x_lim, opt.y_lim, fr_in(end:-1:1,:,:));
set(gca,'YDir','normal');
hold on;

video_time = (i-1) / opt.frameRate;
rig_time = video_time + opt.oneRigTime - opt.oneVideoTime;

time_past_win = mod( rig_time, opt.timebase );

win_start_time = rig_time - time_past_win;

win_end_time = win_start_time;

new_eeg = contwin(eeg, [win_start_time, win_start_time + time_past_win]);
old_eeg = contwin(eeg, [win_end_time - opt.timebase + time_past_win, win_end_time]);

for n = 1:size(eeg.data,2)
    y_offset = (n-1) * -1;
    plot( conttimestamp(new_eeg) - win_start_time, new_eeg.data(:,n) + y_offset,'w');
    plot( conttimestamp(old_eeg) - win_end_time + opt.timebase,   old_eeg.data(:,n) + y_offset,'b');
end