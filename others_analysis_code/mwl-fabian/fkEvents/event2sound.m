function w = event2sound( t, varargin )
%EVENT2SOUND create sound wave from event times
%
%  w=EVENT2SOUND(events) construct sound wave from vector of event times.
%
%  w=EVENT2SOUND(spikes,parm1,val1,...) specifies additional
%  options. Valid options are:
%   segment - create sound wave for specified time segment only
%   fs - desired sampling frequency
%   slowmotion - slow motion factor
%   slowkernel - true/false the kernels will be slowed down as well
%   kernel - 'box'/'gauss' or a custom kernel
%   kernel_width - width/standard deviation of kernel
%   kernel_fs - sampling frequency of custom kernel
%   amplitude - vector of kernel amplitudes for each event
%

%  Copyright 2007-2009 Fabian Kloosterman

%check arguments
if nargin<1
  help(mfilename)
  return
end

options = struct( 'fs', 8000, 'segment', [], 'kernel', 'gauss', ...
                  'kernel_width', 0.005, 'kernel_fs', [], 'slowmotion',1, ...
                  'amplitude', 1, 'slowkernel', false);

options = parseArgs( varargin, options );

if ~isnumeric(t) || ~isvector(t)
    error('event2sound:invalidArgument', 'Invalid event time vector')
end

n = numel(t);

kernel_type = 0;

if ischar(options.kernel) && ismember( options.kernel, {'gauss', 'box'})
  options.kernel_fs = options.fs;
end

options.fs = options.fs.*options.slowmotion;

if ~options.slowkernel
  options.kernel_fs = options.kernel_fs.*options.slowmotion;
end

if isempty(options.segment)
  options.segment = [min(t) max(t)];
end

if isequal( options.kernel, 'gauss' )
  options.kernel = normalize(gaussn( options.kernel_width, 1./options.kernel_fs ),1,'max');
elseif isequal( options.kernel, 'box')
  options.kernel = ones( round(options.kernel_width.*options.kernel_fs), 1 );
elseif isnumeric( options.kernel ) && isvector(options.kernel)
  options.kernel = options.kernel(:);
elseif isnumeric(options.kernel) && size(options.kernel,1)==n
  kernel_type = 1;
else
  error('event2sound:invalidArgument', 'Invalid kernel')
end


if isscalar(options.amplitude) 
  options.amplitude = zeros(n,1)+options.amplitude;
elseif ~isvector(options.amplitude) || numel(options.amplitude)~=n
  error('event2sound:invalidArgument', 'Invalid amplitude')
end

if isempty(options.kernel_fs)
  error('event2sound:invalidArgument', ['Please specify a valid kernel ' ...
                      'sampling rate'])
end


switch kernel_type
 case 0 %single kernel for all events
  %resample kernel
  if options.fs~=options.kernel_fs
    Lkernel = numel(options.kernel);
    options.kernel = interp1( (1:Lkernel)', options.kernel, ...
                              (1:(options.kernel_fs/options.fs):Lkernel)');
  end
  %expand event vector
  w = map( t(:), options.amplitude(:), ...
           'grid', {(options.segment(1):(1./options.fs):options.segment(end))'}, ...
           'function', @sum, 'default', 0);
  
  %convolve with kernel
  w = conv2( w, options.kernel, 'same' );
  
 case 1 %different kernel for each event
  %resample kernels
  Lkernel = size(options.kernel,2);
  if options.fs~=options.kernel_fs
    options.kernel = interp1( (1:Lkernel)', options.kernel', ...
                              (1:(options.kernel_fs/options.fs):Lkernel)');
  end
  
  %apply amplitude
  options.kernel = bsxfun( @times, options.kernel, options.amplitude(:)' );

  Lkernel = size(options.kernel,1);
  
  idx = bsxfun( @plus, ( ( 0:(Lkernel-1) ) - (0.5*Lkernel-0.5) )./options.fs, t(:) )';
  w = map( idx(:), options.kernel(:), 'grid', {(options.segment(1):(1./options.fs):options.segment(end))'},...
       'function', @sum, 'default', 0);
  
end


