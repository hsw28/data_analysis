function props = waveform_props( wave_mean, maxchan )
%WAVEFORM_PROPS waveform properties
%
%  props=WAVEFORM_PROPS(wavemean) calculates the waveform peak and trough
%  amplitudes (in ad units), the width and half width (in samples). All
%  these properties are calculated for the channel with the largest peak
%  only and are defines as:
%   peak_amp - largest value in waveform
%   trough_amp - smallest value in waveform, following the peak
%   width - time (in samples) between peak and trough
%   half_width - waveform width at half peak height (in samples)
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return
end

%assume size of wave_mean is: nchannels x nsamples

if nargin<2 || isempty(maxchan)
    %find maxchan in wave_mean data
    [dummy, maxchan] = max( max( wave_mean, [], 2) ); %#ok
elseif maxchan<1 || maxchan>size(wave_mean,1)
    error('Invalid maxchan parameter')
end

if ~all( wave_mean(:)==0 )
  
  [props.peak_amp, peak_i] = max( wave_mean(maxchan, :) );
  [props.trough_amp, trough_i] = min( wave_mean(maxchan, peak_i:end) );
  trough_i = trough_i + peak_i - 1; %correct trough indices, since we started at peak_i
  
  [zp, zn] = zerocrossing( wave_mean(maxchan,:)' - 0.5*props.peak_amp );
  
  if numel(zp)>1
    [tmp, tmp_i] = min( abs(zp - peak_i) ); %#ok
    zp = zp(tmp_i);
  end
  if numel(zn)>1
    [tmp, tmp_i] = min( abs(zn - peak_i) ); %#ok
    zn = zn(tmp_i);
  end
  
  props.width = trough_i - peak_i;
  props.half_width = zp - zn;
  
else
  
  props = struct( 'peak_amp', 0, 'trough_amp', 0, 'width', NaN, 'half_width', ...
                  NaN );
  
end

    