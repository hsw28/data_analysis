function [cor, trig, ev] =  struct_xcorr(structure, lags)
% computes the cross correlation of individual struct indecies, each index
% must have a .event_times variable that contains all the times overwhich the
% cross correlations are to be computed.
%
% Additionally lags can be specified
% [Corr, Trigger, Event] = structureER_XCORR(structure, lag_vector)


n_corr_total = (length(structure)-1)*(length(structure)/2);

cor = nan(n_corr_total,length(lags)-1);
trig =nan(n_corr_total,1); 
ev =  nan(n_corr_total,1);

ncorr = 0;


% do calculations
for i=1:length(structure)
    for j=i+1:length(structure)
        ncorr = ncorr+1;
        %size(args.time_window)
        cor(ncorr,:) = psth(structure(i).event_times, structure(j).event_times', 'lags', lags);
        trig(ncorr) = i;
        ev(ncorr) = j;
    end
end

end


