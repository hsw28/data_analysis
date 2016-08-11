function c = contcombine(c, cadd, varargin)
% CONTCOMBINE - combine several cont structures, interpolating data
  
  a = struct('timewin', [],...
             'nsamps', [],...
             'samplerate', [],...
             'interp_method', 'cubic');
  
  a = parseArgsLite(varargin,a);
  
  %%% interp cdats to be combined so they have the same time basis as 'c'
  if isstruct(cadd), 
    cadd = {cadd};
  end
  
  if ~isempty(cadd) && ~iscell(cadd)
    error('conts to combine must be in a cell array');
  end
  
  if isempty(a.timewin),
    tstart = c.tstart;
    tend = c.tend;
    for k = 1:length(cadd)
      tstart = max([tstart cadd{k}.tstart]);
      tend = min([tend cadd{k}.tend]);
    end
    timewin = [tstart tend];
  else
    timewin = a.timewin;
  end
  
  if isempty(a.nsamps) && isempty(a.samplerate);
    a.samplerate = c.samplerate;
  end

  if sum([~isempty(a.samplerate) ~isempty(a.nsamps)]) ~= 1,
    error('exactly one of samplerate/nsamps must be provided');
  end

  % if requested timewin, nsamps or samplerate has changed, interp c
  if all(timewin ~= [c.tstart c.tend]) ||...
        (~isempty(a.samplerate) && a.samplerate ~= c.samplerate) ||...
        (~isempty(a.nsamps) && a.nsamps ~= size(c.data,1)),
    c = continterp(c, 'timewin', timewin,...
                   'nsamps', a.nsamps,...
                   'samplerate', a.samplerate);
  end

  % nsamps in c is what we want to match:
  a.nsamps = size(c.data, 1);
  a.samplerate = [];
    
  for k = 1:length(cadd)
    ck = cadd{k};
    ck = continterp(ck, 'timewin', timewin,...
                    'nsamps', a.nsamps,...
                    'method', a.interp_method);
    
    % concatenate data
    c.data = [c.data ck.data];

    if ~isempty(c.chanvals) && ~isempty(ck.chanvals),
      c.chanvals = [c.chanvals ck.chanvals];
    else
      c.chanvals = [];
    end
    
    if ~isempty(c.chanlabels) && ~isempty(ck.chanlabels),
      c.chanlabels = [c.chanlabels ck.chanlabels];
    else
      c.chanlabels = [];
    end
    
    % get extent of data
    c.datarange = vertcat(c.datarange,...
                          ck.datarange);

    % hard to make sense of once we've changed time base for some channels
    c.nbad_start = NaN;
    c.nbad_end = NaN;
    c.max_tserr = NaN;
    
    c.name = [c.name '&' ck.name];
  end
  
