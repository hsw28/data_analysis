function [data segs_samp] = contsegdata(cont, segs)
% CONTSEGDATA get raw data points from segments, no time info
  
  segs_samp = round((segs - cont.tstart) * cont.samplerate)+1;

  dat_use = false(size(cont.data,1),1);
  
  for k = 1:size(segs,1),
    
    samps_i = segs_samp(k,1):segs_samp(k,2);
    dat_use(samps_i) = true;

    % don't include timepoints with NaNs in any channel
    dat_use(samps_i(any(isnan(cont.data(samps_i,:)),2))) ...
        = false;

  end

  data = cont.data(dat_use,:);