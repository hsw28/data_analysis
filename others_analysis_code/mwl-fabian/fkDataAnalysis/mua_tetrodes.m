function varargout = mua_tetrodes( rootdir, varargin )
%MUA_TETRODES extract multi unit activity
%
%  mua=MUA_TETRODES(rootdir)
%
%  mua=MUA_TETRODES(rootdir,param1,val1,...)
%   segment - time segment
%   amplitude - amplitude filter (uV)
%   width - spike width filter (us)
%   tetrodes - tetrode selection (vector of tetrode id, or cell array)
%   separate - false/true keep mua for tetrodes separate
%

%  Copyright 2006-2008 Fabian Kloosterman

%check arguments
if nargin<1
    help(mfilename)
    return
end

options = struct( 'segment', [], 'amplitude', 100, 'width', [], 'tetrodes', [], 'separate', false );
options = parseArgs( varargin, options );

if ~isempty(options.segment) && (~isequal(size(options.segment),[1 2]) || diff(options.segment<=0) )
    error('mua_tetrodes:invalidArgument', 'Invalid time segment')
end

if ~isempty(options.amplitude) && (~isnumeric(options.amplitude) || ~all(options.amplitude>=0) || numel(options.amplitude)>2)
    error('mua_tetrodes:invalidArgument', 'Invalid amplitude range')
end

if ~isempty(options.width) && (~isnumeric(options.width) || numel(options.width)>2)
    error('mua_tetrodes:invalidArgument', 'Invalid width range')    
end

if ~isempty(options.tetrodes)
    if isnumeric(options.tetrodes)
        options.tetrodes = {'id', options.tetrodes};
    elseif ~iscell(options.tetrodes)
        error('mua_tetrodes:invalidArgument', 'Invalid tetrode selection')
    end
end

if options.separate
   varargout = {};
else
   varargout = {[]};
end

% import tetrode information
tt_info = import_tetrode_info( rootdir );

% select tetrodes
if ~isempty( options.tetrodes)
    tt_idx = find( select_tetrode( tt_info, options.tetrodes{:} ) );
else
    tt_idx = 1:numel(tt_info);
end

%go through each tetrode
for k = tt_idx(:)'
   
    %construct name of feature file
    fname = strrep(tt_info(k).waveform_file, '.tt', '.pxyabw');
    
    %open file
    f = mwlopen( fullfile( rootdir, fname ) );
  
    %check for new amplitude parameters
    if all( ismember( {'t_fpx', 't_fpy', 't_fpa', 't_fpb'}, name(f.fields) ) )
        amp_fields = {'t_fpx', 't_fpy', 't_fpa', 't_fpb'};
    else
        amp_fields = {'t_px', 't_py', 't_pa', 't_pb'};
    end
    
    %load spike features
    if ~isempty(options.segment)
        data = loadrange( f, {'time', amp_fields{:}, 't_maxwd'}, options.segment, 'time' );
    else
        data = load( f, {'time', amp_fields{:}, 't_maxwd'} );      
    end
  
    valid = true( size( data.time ) );
  
    if ~isempty(options.amplitude)
        %convert threshold (in uV) to AD units
        th = bsxfun( @times, 2048.*tt_info(k).gain', options.amplitude./10000000 );
        valid = valid & ( inrange( data.(amp_fields{1}), th(1,:) ) | inrange( data.(amp_fields{2}), th(2,:) ) | ...
                          inrange( data.(amp_fields{3}), th(3,:) ) | inrange( data.(amp_fields{4}), th(4,:) ) );
  end
  
  if ~isempty(options.width)
      %convert width (in us) to samples
      w = options.width .* tt_info(k).rate ./ 1000000;
      valid = valid & inrange( data.t_maxwd, w );
  end
    
  if options.separate
    varargout{end+1} = data.time(valid)';
  else
    varargout{1} = [varargout{1}; data.time(valid)'];
  end  
  
end


if ~options.separate
  varargout{1} = sort(varargout{1});
else
  varargout{1} = varargout;
end

