function clusters = import_waveform( rootdir, clusters, tetrodes )
%IMPORT_WAVEFORM import spike waveform
%
%  clusters=IMPORT_WAVEFORM(rootdir,clusters,tetrodes) import spike
%  waveform means (calculate if necessary) and waveform
%  properties for all clusters. Waveform values are converted to mV.
%

%  Copyright 2007-2008 Fabian Kloosterman

%Does wave dir exist?
if ~exist( fullfile( rootdir, 'wave' ), 'dir' )
    [success, msg, msgid] = mkdir(fullfile(rootdir, 'wave')); %#ok
end

%loop through all clusters
for c = 1:length(clusters)

  clusters(c).amplitude = double(clusters(c).amplitude);
  
  if nargin>2 && ~isempty(tetrodes)

    tt_id = find( [tetrodes.id] == clusters(c).tetrode );
    
    waveform_file = fullfile(rootdir,'..','..', tetrodes(tt_id).waveform_file);
    spike_id = clusters(c).spike_id;
    
    g = tetrodes(tt_id).gain;
    
    clusters(c).waveforms = @(varargin) load_cluster_waveforms(waveform_file,spike_id,g,varargin{:});
    

    tt_rate = tetrodes(tt_id).rate;
    [clusters(c).wave_mean clusters(c).wave_std props] ...
        = update_waveform( fullfile(rootdir, 'wave'), ...
                           waveform_file , ...
                           fullfile(rootdir, 'clusters', clusters(c).name), clusters(c).maxchan );
    
    clusters(c).wave_mean = clusters(c).wave_mean';
    clusters(c).wave_std = clusters(c).wave_std';
    
    clusters(c).amplitude = double( clusters(c).amplitude );
    for chan = 1:4
      clusters(c).amplitude(:,chan) = (10 * clusters(c).amplitude(:,chan) ./ 2048) ./ g(chan) * 1e3 ;
      clusters(c).wave_mean(:,chan) = (10 * clusters(c).wave_mean(:,chan) ./ 2048) ./ g(chan) * 1e3 ;
      clusters(c).wave_std(:,chan)  = (10 * clusters(c).wave_std(:,chan) ./ 2048) ./ g(chan) * 1e3 ;
    end
    
    clusters(c).wave_peak_amp   = (10 * props.peak_amp ./ 2048) ./ g(clusters(c).maxchan) * 1e3 ;
    clusters(c).wave_trough_amp = (10 * props.trough_amp ./ 2048) ./ g(clusters(c).maxchan) * 1e3 ;
    clusters(c).wave_width = 1000*props.width ./ tt_rate;
    clusters(c).wave_half_width = 1000*props.half_width ./ tt_rate;
    
  end
  
end

function w = load_cluster_waveforms( wavefile, spike_id, gain, idx, convert)  

if nargin<4 || isempty(idx) || ~isnumeric(idx)
  idx = 1:numel(spike_id);
end

if nargin<5 || isempty(convert) || ~isnumeric(convert)
  convert = 0;
else
  convert = ~isequal(convert,0);
end

f = mwlopen( wavefile );
w = load( f, 'waveform', spike_id(idx) );
w = w.waveform;

if convert
  w = bsxfun(@rdivide, 10.*double(w)./2048, gain(:) ) * 1e3;
end