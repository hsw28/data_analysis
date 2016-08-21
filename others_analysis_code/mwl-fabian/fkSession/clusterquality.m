function scores = clusterquality( rootdir, epoch_info, clusters, tetrodes )
%CLUSTERQUALITY compute cluster quality scores
%
%  scores=CLUSTERQUALITY(rootdir, epochinfo, clusters, tetrodes)
%  computes/updates cluster quality scores of all clusters in a given
%  epoch.
%

%  Copyright 2007-2008 Fabian Kloosterman

%create initial array of quality scores for clusters (including tetrode
%id and cluster id)

flds = {'tetrode', 'cluster_id', 'lratio', 'isolation_distance', ...
        'cluster_sepation', 'noise_separation', 'clipping', 'drift'};

scores = NaN( numel(clusters), numel(flds) );

if numel(clusters)==0
  return
end

scores(:,1:2) = [ vertcat(clusters.tetrode) vertcat(clusters.cluster_id) ];

                  
%does cluster quality file exist?
quality_file = fullfile( epoch_info.rootdir, 'clusters', 'quality.dat');
if exist( quality_file, 'file' )
  
  %yes, load existing scores...
  f = mwlopen( quality_file );
  file_create_date = getFirstParam(f.header,'Date');
  file_create_date = datenum( file_create_date, 'mmm dd HH:MM:SS yyyy');
  old_scores = load( f );
  old_scores = struct2cell( old_scores );
  old_scores = vertcat( old_scores{:} )';
  
  %and initialize quality array with loaded values
  if ~isempty(old_scores)
    [b,loc] = ismember( scores(:,1:2) , old_scores(:,1:2), 'rows' );
    scores( b, : ) = old_scores( loc(b), : );
  end
  
else
  file_create_date = -Inf;
end

%loop through all tetrodes with clusters
tt = unique( [clusters.tetrode] );

for k=tt

  %find clusters that need update  
  tt_idx = find( [tetrodes.id]==k ); 
  cl_idx = find( [clusters.tetrode]==k & [clusters.date]> file_create_date );
  
  if isempty(cl_idx)
    continue
  end
  
  %load amplitudes from pxyabw file for given epoch
  wavefile = fullfile( rootdir, ...
                       strrep(tetrodes(tt_idx).waveform_file, '.tt', '.pxyabw') );
  
  f = mwlopen( wavefile );
  
  if all( ismember( {'t_fpx', 't_fpy', 't_fpa', 't_fpb'}, name(f.fields) ) )
      newfields = true;
      data = loadrange( f, {'id', 't_fpx', 't_fpy', 't_fpa', 't_fpb'}, epoch_info.timestamp, 'time' );
  else
      newfields = false;
      data = loadrange( f, {'id', 't_px', 't_py', 't_pa', 't_pb'}, epoch_info.timestamp, 'time' );
  end
  
  %correct spike id
  for j=cl_idx
    
    if isempty( clusters(j).spike_id)
      continue
    end
    
    clusters(j).spike_id = clusters(j).spike_id - data.id(1) + 1;
    clusters(j).spike_id( clusters(j).spike_id<1 | ...
                          clusters(j).spike_id>numel(data.id) ) = [];
    
  end

  %compute mahalanobis distances
  if newfields
      D2 = clustermahal( double( [data.t_fpx' data.t_fpy' data.t_fpa' ...
                          data.t_fpb'] ), {clusters(cl_idx).spike_id} );
  else
      D2 = clustermahal( double( [data.t_px' data.t_py' data.t_pa' ...
                          data.t_pb'] ), {clusters(cl_idx).spike_id} );
  end
  
  %compute cluster quality scores
  scores(cl_idx,3) = lratio( D2, 4, {clusters(cl_idx).spike_id} );
  scores(cl_idx,4) = isolation_distance( D2, {clusters(cl_idx).spike_id} );
  
end

%save file
flds = mwlfield( flds, 'double', 1 );
hdr =  header('Date', datestr(now, 'mmm dd HH:MM:SS yyyy') );
mwlcreate( quality_file, 'feature', 'Fields', flds, 'Mode', 'overwrite', ...
           'Header', hdr, 'Data', mat2cell(scores,size(scores,1), ...
                                           ones(size(scores,2),1)),'FileFormat', 'ascii');
