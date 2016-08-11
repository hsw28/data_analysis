function [xc lags_t] = contxcorr(cs, varargin)
% CONTXCORR do an xcorr between 2 cdat chans, 2 cdat structs, or acorr on
% 1 chan/struct. Returns array for several bouts
%
% -bouts can be overlapping/unordered.
  
% TODO:
% -deal with short windows? 
% -maxlags in t?
  
  a = struct(...
      'chans', [],...
      'chanlabels', [],...
      'scaleopt', 'unbiased_coeff',...
      'maxlag_t', [],...
      'bouts',[],...
      'autoresample', true);
  
  a = parseArgsLite(varargin,a);
  
  % make sure we only have 1 or 2 channels of data, combine them into a
  % single, 1 or 2-channel cdat struct.

  % figure out the smallest timewin we can use to calculate xcorrs
  timewin = [max([cs.tstart]) min([cs.tend])];
  if ~isempty(a.bouts),
    timewin = [max(cs.tstart, min(a.bouts(:))) ....
               min(cs.tend, max(a.bouts(:)))];
  end
  
  if diff(timewin)<=0, 
    error(['no overlap between cdat inputs (or zero diff between first/last ' ...
           'bout edge)']);
  end

  % hack in 'unbiased_coeff' xcorr method
  if strcmp(a.scaleopt, 'unbiased_coeff')
    unbiased_coeff = true;
    a.scaleopt = 'unbiased';
  else
    unbiased_coeff = false;
  end

  
  switch length(cs)
   case 1,
    cdat = contwin(contchans(cs, 'chans', a.chans, 'chanlabels', a.chanlabels),...
                   timewin);
    
    if all(size(cdat.data,2) ~= [1 2])
      error('Exactly 1 or 2 channels must be specified')
    end
   case 2,
    if ~isempty(a.chans) || ~isempty(a.chanlabels),
      error(['If 2 cdats are provided, ''chans'' and ''chanlabels'' may ' ...
             'not  be provided (use contchans on inputs)']);
    end
    
    if size(cs(1).data,2) ~= 1 || size(cs(2).data,2) ~= 1,
      error(['If 2 cdats are provided, they must have single data channels ' ...
             '(use contchans on inputs)']);
    end

    % -align samples by interpolation so that xcorr makes sense
    % -use highest sampling rate for shared sampling rate 
    cdat = contcombine(cs(1), cs(2),...
                       'samplerate', max([cs.samplerate]),...
                       'timewin', timewin);
   otherwise
    error('Only 1 or 2 cdat structs can be cross-correlated');
  end
  
  % convert lags to samples
  maxlags = ceil(a.maxlag_t .* cdat.samplerate);
  
  for k = 1:size(a.bouts,1);
    cdat_win = contwin(cdat,a.bouts(k,:));
    A = cdat_win.data(:,1);
    if size(cdat_win.data,2) == 2, % xcorr
      B = cdat_win.data(:,2);
    else % autocorr
      B = A;
    end

    [xc(:,k) lags] = xcorr(A, B, maxlags, a.scaleopt);
  
    if unbiased_coeff && any(xc(:,k)) % avoid div/0
      % scale unbiased xcorr so that central peak is exactly 1
      xc(:,k) = xc(:,k) ./ xc(maxlags+1,k);
    end
    
  end

  % calculate lags in seconds
  lags_t = lags ./ cdat.samplerate;
  