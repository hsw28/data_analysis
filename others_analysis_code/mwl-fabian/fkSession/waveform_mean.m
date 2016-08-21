function [wave_mean, wave_std] = waveform_mean( ttfile, idx, maxchan, center )
%WAVEFORM_MEAN calculate waveform mean
%
%  [wavemean,wavestd]=WAVEFORM_MEAN(ttfile,id) calculates the mean and
%  standard deviation of the spike waveforms in the tt-file for the
%  spikes records indicated by the id vector. The waveforms are centered
%  at the peak of the waveform in the channels with the largest peak
%  before calculating the mean. The peak is centered at the 10th sample.
%
%  [...]=WAVEFORM_MEAN(ttfile,id,maxchan) uses the specified channel for
%  finding the peak for centering.
%
%  [...]=WAVEFORM_MEAN(ttfile,id,maxchan,center) centers the waveform at
%  specified sample.
%

%  Copyright 2007-2008 Fabian Kloosterman

if nargin<2
    help(mfilename)
    return
end

if nargin<3 || isempty(maxchan)
    maxchan = 0;
end

if nargin<4 || isempty(center)
    center = 10;
end

%open file
wf = mwlopen( ttfile );
nchan = get(wf,'nchannels');

if maxchan<0 || maxchan>nchan
    error('waveform_mean:invalidArguments','Invalid maxchan parameter')
end

%load waveforms, note that all waveforms are loaded at once
w = load( wf, {'all'}, idx );
w = w.waveform;

%the size of w is assumed to be: nchannels x nsamples x nspikes

if ~maxchan
    %determine maxchan ourselves at the expense of more computation time
    [m, mi] = max( w, [], 2 ); % find maximum in spike window, size is now: nchannels x 1 x nspikes
    [dummy, maxchan] = max( mean( m, 3 ) ); %#ok find largest mean(maximum) across channels
    %m = m(maxchan,:,:); %size of m is: 1 x 1 x nspikes
    mi = mi(maxchan,:,:); %size of mi is: 1 x 1 x nspikes
else
    [m, mi] = max( w(maxchan,:,:), [], 2 ); %#ok size of m and mi is: 1 x 1 x nspikes
end

%center waveforms
[row_i, col_i, plane_i] = ndgrid( 1:size(w,1), 1:size(w,2), 1:size(w,3) );
col_shift = col_i + repmat( mi - center, [size(w,1), size(w,2), 1] );
%row_shift = row_i + repmat( mi - center, [size(w,1), size(w,2), 1] );
col_shift( col_shift>size(w,2) | col_shift<1 ) = NaN;
%row_shift( row_shift>size(w,1) | row_shift<1 ) = NaN;
%valid = ~isnan(row_shift);
valid = ~isnan(col_shift);
%row_shift = mod( row_shift(valid) + size(w,1) - 1, size(w,1) ) + 1;
col_shift = mod( col_shift(valid) + size(w,2) - 1, size(w,2) ) + 1;

wshift = NaN( size(w) );
%wshift( sub2ind( size(w), row_i(valid), col_i(valid), plane_i(valid) ) ) = w( sub2ind( size(w), row_shift, col_i(valid), plane_i(valid) ) );
wshift( sub2ind( size(w), row_i(valid), col_i(valid), plane_i(valid) ) ) = w( sub2ind( size(w), row_i(valid), col_shift, plane_i(valid) ) );

%calculate mean waveform and standard deviation
wave_mean = nanmean( wshift, 3 ); %size of wave_mean is: nchannels x nsamples
wave_std = nanstd( wshift, [], 3); %size of wave_std is: nchannels x nsamples