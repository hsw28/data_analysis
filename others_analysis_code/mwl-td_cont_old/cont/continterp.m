function c = continterp(c,varargin)
% CONTINTERP resample and interpolate cont struct data to match timestamps
%
% param/value pair args:
%
%  'timewin', tstart/tend of resulting cdat (default same as input)
%  'nsamps'/'samplerate': specify interp points
%  'method', interp1 method ({'cubic'}, 'spline', 'linear', 'nearest' etc)
%
% todo:
%   -performance: bracket timewin before resample&interp1
  
  a = struct(...
      'timewin',[],...
      'nsamps', [],...
      'samplerate',[],...
      'method', 'spline');
  
  a = parseArgsLite(varargin,a);
  
  if isempty(a.timewin),
    if size(c.data,1) > 1e5;
      warning('no timewin provided interpolating entire cont struct');
    end

    a.timewin = [c.tstart c.tend];
    
  end
    
  if sum([~isempty(a.nsamps) ~isempty(a.samplerate)]) ~= 1,
    error('exactly one of nsamps or samplerate must be provided');
  end

  if ~isempty(a.nsamps)
    samplerate_effective = (a.nsamps-1)./diff(a.timewin);
  else
    samplerate_effective = a.samplerate;
  end
  
  
  %%% [bracket requested timerange]

  
  %%% resample data to roughly correct sampling rate (avoid aliasing)
  c = contresamp(c, ...
                 'resample', samplerate_effective./c.samplerate,...
                 'tol', 0.05); % use wide tolerance since we're going to
                               % interp below, anyway
  
  %%% interpolate!

  % generate timestamps of existing data
  x = linspace(c.tstart,c.tend, size(c.data,1));
  
  % generate timestamps of requested samples
  if ~isempty(a.nsamps),
    xi = linspace(a.timewin(1), a.timewin(2), a.nsamps);
  else
    xi = a.timewin(1):1/a.samplerate:a.timewin(2);
  end
  
  disp('interpolating...');

  nchans = size(c.data,2);
  
  % do it channel-by-channel to save memory
  for k = nchans:-1:1 % reverse order so that first loop preallocates
    % blech: interp1 returns data in a row for vector inputs, 
    % last argument says use NaN for extrapolated values
    newdata(:,k) = interp1(x,c.data(:,k), xi, a.method, NaN);
  end
  c.data = newdata;
  
  c.tstart = xi(1);
  c.tend = xi(end);
  c.samplerate = samplerate_effective;
  c = contdatarange(c);

  % hard to say where the bad samples ended up
  c.nbad_start = NaN;
  c.nbad_end = NaN;