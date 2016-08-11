function c = contwin(c, timewin)
% CONTWIN select a time window from a larger cdat struct
  
  if diff(timewin)<=0
    error('timewindow must be of length > 0');
  end
  
  timewin = [max(timewin(1), c.tstart), min(timewin(2), c.tend)];

  % need to add 1 since cdat is 1-indexed (i.e. time difference of 0
  % samples means start with sample #1)
  win_samp = round((timewin - c.tstart) * c.samplerate)+[1,0];

  c = contwinsamp(c, win_samp);
