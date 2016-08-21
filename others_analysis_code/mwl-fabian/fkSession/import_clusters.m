function result = import_clusters (rootdir, tetrodes)
%IMPORT_CLUSTERS import cluster data
%
%  clusters=IMPORT_CLUSTERS(rootdir)
%

%  Copyright 2007-2008 Fabian Kloosterman

VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end

re = 'D(?<day>\d+)_T(?<tetrode>\d+)_CL(?<cluster>\d+).*';

result = struct('date', {}, 'name', {}, 'tetrode', {}, 'cluster_id', {}, ...
                'spike_id', {}, 'timestamp', {}, 'amplitude', {}, ...
                'maxchan', {}, 'quality', {}, 'nspikes', {});

%find all cluster files
filelist = dir( fullfile(rootdir, 'clusters', '*.cluster') );

ncluster = 0;

%loop through all clusters
for f = 1:length(filelist)
    
  if filelist(f).isdir==0
    
    r = regexp(filelist(f).name, re, 'names');
    
    if isempty(r)
      continue
    end
    
    ncluster = ncluster + 1;
    
    %gather info
    result(ncluster).name = filelist(f).name;
    result(ncluster).tetrode = str2num(r.tetrode); %#ok
    result(ncluster).cluster_id = str2num(r.cluster); %#ok
    
    tt_idx = [tetrodes.id]==result(ncluster).tetrode;
    result(ncluster).source = tetrodes(tt_idx).source;
    result(ncluster).source_name = tetrodes(tt_idx).source_name;
    result(ncluster).sensor_name = tetrodes(tt_idx).sensor_name;
    
    cf = mwlopen( fullfile(rootdir, 'clusters', filelist(f).name) );
    
    cluster_create_date = getFirstParam(cf.header,'Date');
    %xclust generated Date parameter in header has (redundant) format:
    %Wed Feb 10 22:13:57 2005 - exclude first 4 characters for proper decoding
    result(ncluster).date = datenum( cluster_create_date(5:end), 'mmm dd HH:MM:SS yyyy');
    
    if all( ismember( {'t_fpx', 't_fpy', 't_fpa', 't_fpb'}, name(cf.fields) ) )
        newfields = true;
        data = load(cf, {'id', 'time', 't_fpx', 't_fpy', 't_fpa', 't_fpb'});
    else
        newfields = false;
        data = load(cf, {'id', 'time', 't_px', 't_py', 't_pa', 't_pb'});
    end
    
    if numel(data.id)>0
      result(ncluster).spike_id = data.id';
      result(ncluster).timestamp = data.time';
      if newfields
          result(ncluster).amplitude = [data.t_fpx; data.t_fpy; data.t_fpa; data.t_fpb]';
      else
          result(ncluster).amplitude = [data.t_px; data.t_py; data.t_pa; data.t_pb]';
      end
      [m result(ncluster).maxchan] = max( mean(result(ncluster).amplitude) ); %#ok
    else
      result(ncluster).spike_id=[];
      result(ncluster).timestamp = [];
      result(ncluster).amplitude = zeros( 0, 4);
      result(ncluster).maxchan = [];
    end
    
    hdr = cf.header;
    if any(hasParam(hdr, 'Cluster Score'))
        score = getFirstParam(hdr,'Cluster Score');
        result(ncluster).quality = str2num(score); %#ok
    else
        result(ncluster).quality = -1;
    end
    
    result(ncluster).nspikes = length(result(ncluster).timestamp);
    
    result(ncluster).props = @(varargin) load_props( fullfile(rootdir, 'clusters'), filelist(f).name, varargin{:});
    
  end
  
end

verbosemsg(['Imported ' num2str(numel(result)) ' clusters.']);