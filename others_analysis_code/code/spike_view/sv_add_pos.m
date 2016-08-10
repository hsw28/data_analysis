function f = sv_add_pos(f)

sv = guidata(f);

timestamp = conttimestamp(sv.pos.lin_filt);
plot(sv.axis_a,sv.pos.lin_filt.data,timestamp);
set(sv.axis_a,'YDir','reverse')