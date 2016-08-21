function [cor, trig, ev] =  cluster_xcorr(clust, varargin)
%
%    DEPRICATED, replaced with struct_xcorr, please use that from now on
%
% computes the cross correlation of individual struct indecies, each index
% must have a .times variable that contains all the times overwhich the
% cross correlations are to be computed.
%
% Additionally lags can be specified
% [Corr, Trigger, Event] = CLUSTER_XCORR(clusters_structure)
% [Coor, Trigger, Event] = CLUSTER_XCORR(..., 'lags', lag_vector)
% [Coor, Trigger, Event] = CLUSTER_XCORR(..., 'idx_ignore , idx)


args = struct('lags', [-.15:.005:.15], 'idx_ignore', [], 'time_window', [], 'use_frames', []);
args = parseArgs(varargin{:}, args);


%%% Removal of the indecies that are to ignored for the calculation
idx = 1:length(clust);
idx2 = logical(idx);
idx2(args.idx_ignore)=0;
idx = idx(idx2);


%idx = idx(~ismember(1:length(idx), argg.idx_ignore));
%idx = idx(setdiff(1:length(idx),args.idx_ignore)); % both do same thing as
%above but slower by about 10-20 times

n_corr_total = (length(idx)-1)*(length(idx)/2);

cor = nan(n_corr_total,length(args.lags)-1);
trig =nan(n_corr_total,1); 
ev =  nan(n_corr_total,1);

ncorr = 0;
disp(['Computing xcorr for ', num2str(length(clust)),...
    ' clusters. This requires ', num2str(n_corr_total), ' calculations.']);

% setup neccesary vectors
for i=1:length(clust)
    if isempty(args.time_window)
        data(i).time = clust(i).time;
    else
        data(i).time = clust(i).load_window({'time_window', args.time_window});
    end
end

% do calculations
for i=1:length(idx)
    for j=i+1:length(idx)
        ncorr = ncorr+1;
        %size(args.time_window)
        cor(ncorr,:) = psth(data(idx(i)).time, data(idx(j)).time', 'lags', args.lags);
        trig(ncorr) = idx(i);
        ev(ncorr) = idx(j);
    end
end

end


