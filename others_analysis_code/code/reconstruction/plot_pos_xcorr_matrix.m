function f = plot_pos_xcorr_matrix(xcorr_matrix)

f = figure;

n_per_side = size(xcorr_matrix.data,1);

n_plots = n_per_side^2;

for m = 1:n_per_side
    for n = 1:n_per_side
        ax(n + (m-1)*n_per_side) = ...
            subplot(n_per_side,n_per_side,...
                         n+(m-1)*n_per_side);
                     
        plot(xcorr_matrix.lags,...
                   reshape(xcorr_matrix.data(m,n,:),1,[]));
        title(['m:', num2str(m), ', n:', num2str(n)]); hold on;
        plot([0 0], [0 1],'k');
        %ylim([0.75 1.25]);
    end
end