function [wave_mean, wave_std, wave_props] = update_waveform( rootdir, tt_file, cluster_file, maxchan )
%UPDATE_WAVEFORM update spike waveform
%
%  [wavemean,wavestd,waveprops]=UPDATE_WAVEFORM(rootdir,ttfile,clusterfile)
%  loads previously calculated mean waveforms or, if cluster file is newer than
%  wave file, calculates mean waveforms for the cluster file. Returns the
%  mean, standard deviation and properties (peak, trough, etc.) of the
%  waveform. Waveforms are centered at the peak of the waveform in the
%  channel with the largest peak.
%
%  [...]=UPDATE_WAVEFORM(...,maxchan) the specified channel is used to
%  center the waveform, rather than finding the channel with the largest
%  peak (saves computation).
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<3
    help(mfilename)
    return
end

if nargin<4
    maxchan = [];
end

%extract day, tetrode and cluster from cluster file name
re = 'D(?<day>\d+)_T(?<tetrode>\d+)_CL(?<cluster>\d+).cluster';
r = regexp(cluster_file, re, 'names');
r.day = str2double(r.day);
r.tetrode = str2double(r.tetrode);
r.cluster = str2double(r.cluster);

%find creation date in cluster file
cf = mwlopen( cluster_file );
cluster_create_date = cf.header(1).('Date');
%xclust generated Date parameter in header has (redundant) format:
%Wed Feb 10 22:13:57 2005 - exclude first 4 characters for proper decoding
cluster_create_date = datenum( cluster_create_date(5:end), 'mmm dd HH:MM:SS yyyy');
   
%Does wave file exist?
wave_filename = sprintf('D%02d_T%02d_CL%03d.wave', r.day, r.tetrode, r.cluster);
if exist( fullfile( rootdir, wave_filename ), 'file' )
  %check creation date
  f = mwlopen( fullfile( rootdir,  wave_filename) );
  wave_create_date = f.header(1).('Date');
  wave_create_date = datenum( wave_create_date, 'mmm dd HH:MM:SS yyyy');
  wave_data = load( f );
  wave_mean = wave_data.mean;
  wave_std = wave_data.std;
else
  wave_create_date = -Inf;
end    
    
%is cluster newer than wave file?
if cluster_create_date > wave_create_date

  fprintf('Updating waveform data: %s ...\n', wave_filename)
    
  %load spike ids
  ids = load( cf, 'id' );
    
  if isempty(ids.id)
    wave_mean = zeros(4,32);
    wave_std = NaN(size(wave_mean));
  else
    %center and average waveform
    [wave_mean, wave_std] = waveform_mean( tt_file, ids.id, maxchan, 10 );
  end
    
  %save waveform
  flds = mwlfield( {'mean', 'std'}, {'double', 'double'}, size(wave_mean) );
  hdr = header( 'Date', datestr(now, 'mmm dd HH:MM:SS yyyy') );
  mwlcreate( fullfile(rootdir, wave_filename), 'feature', 'Fields', flds, 'Mode', 'overwrite', 'Header', hdr, 'Data', {wave_mean, wave_std});
    
end

%calculate wave properties
wave_props = waveform_props( wave_mean, maxchan);