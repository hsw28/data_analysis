function input = setup_decoding_inputs(exp,ep)

input.exp = exp;
input.ep = ep;

if isfield('position', exp.(ep))
    pos = exp.(ep).position.lin_pos;
    vel = exp.(ep).position.lin_vel;
    pts = exp.(ep).position.timestamp;
else
    pos = exp.(ep).pos.lp;
    vel = exp.(ep).pos.lv;
    ts = exp.(ep).pos.ts;
end

i = 1;
while isnan(pos(1))
    pos(1) = pos(i);
    i = i+1;
end
    
while any(isnan(pos))
    pos(find(isnan(pos))) = pos(find(isnan(pos))-1); %#ok
end

input.pos.lp = pos;
input.pos.lv = vel;
input.pos.ts = ts;

input.param.vel_thold = [.15 Inf];
input.param.amp_thold = [125 Inf];
input.param.spike_width = [-inf inf];

et = exp.(ep).et;
input.t_range = [et(1) mean(et)];
input.d_range = [mean(et) et(2)];

[input.raw_amps input.amp_names] = load_exp_amplitudes(input.exp, input.ep);

