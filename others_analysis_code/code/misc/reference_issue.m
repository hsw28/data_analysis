% script makes some phase-offset sin waves, then subtracts various
%types of reference
% the idea is to see what sorts of phase-shifts are introduced by the
%subtraction

lambda = 10; % traveling-wave wavelength in best direction
freq = 7.5;  % temporal frequency
t = [0:1/1000:0.5];
pos = linspace(0,3,8);
ref_ind = 4;
ref_coef = 0.6
ref_phase_offset = 0;

[T,POS] = meshgrid(t,pos);

v = sin((2*pi).*( (freq .* T) + (POS ./ lambda) ) );  % n_tetrode by n_t array
v_ref = ref_coef .* sin((2*pi).*( (freq .* T(ref_ind,:)) + (POS(ref_ind,:) ./ lambda) + ref_phase_offset) );
v_sub = v - repmat(v_ref,numel(pos),1);

figure;

n_chan = size(v,1);
t_range = [min(t),max(t)];

y_box = [0:n_chan]';

for c = 1:(n_chan+1)
plot(t_range,[y_box(c) y_box(c)]+1/2,'k-');
hold on;
end

for c = 1:n_chan
plot(t,v(c,:)/4 + c,'g-');
plot(t,v_sub(c,:)/4 + c,'b-');
end