function plot_some_slices(r_pos_trig,phases,phase_ind)

n_phases = numel(phase_ind);

for m = 1:n_phases
    n = phase_ind(m);
    figure;
    x_vals = linspace(r_pos_trig(1).x_range(1), r_pos_trig(1).x_range(2), size(r_pos_trig(1).pdf_by_t,1));
    plot(x_vals,r_pos_trig(1).pdf_by_t(:,n)','r');
    hold on;
    plot(x_vals,r_pos_trig(2).pdf_by_t(:,n)','g');
    plot(x_vals,r_pos_trig(3).pdf_by_t(:,n)','b');
    title(['phase: ', num2str(phases(n)/pi), ' pi']);
end