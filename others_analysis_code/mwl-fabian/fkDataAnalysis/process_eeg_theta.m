function process_eeg_theta( rootdir, epoch, Fs_new, varargin )
%PROCESS_EEG_THETA theta oscillation detection
%
%  PROCESS_EEG_THETA(rootdir,epoch) find theta oscillations in all eeg
%  signals for the specified epoch. Peaks, troughs and zero-crossings are
%  detected after filtering in the theta band. The signal is then
%  resampled at 100Hz and the envelope and phase is computed using the
%  hilbert transform.
%
%  PROCESS_EEG_THETA(rootdir,epoch,Fs_new) specifies the sampling
%  frequency for the hilbert transform.
%
%  PROCESS_EEG_THETA(rootdir,epoch,Fs_new,param1,val1,...) specifies
%  additional eeg signal selection criteria, which are passed on to the
%  select_eeg function. 
%

%---VERBOSE---
VERBOSE_MSG_ID = mfilename; %#ok
if evalin('caller', 'exist(''VERBOSE_MSG_LEVEL'',''var'')')
  VERBOSE_MSG_LEVEL = evalin('caller', 'VERBOSE_MSG_LEVEL') + 1; %#ok
else
  VERBOSE_MSG_LEVEL = 1; %#ok
end
%---VERBOSE---

if nargin<2
  help(mfilename)
  return
end

if nargin<3 || isempty(Fs_new)
  Fs_new = 100;
end

eeg_signals = import_eeg( rootdir, epoch );

idx = select_eeg( eeg_signals, varargin{:} );

if isempty(idx)
  verbosemsg('No signals to be processed...');
  return
end

for k = idx(:)'
  
  verbosemsg(['Loading signal ' num2str(k) '...']);  
  [data, t] = eeg_signals(k).load();
  
  %filter
  verbosemsg(['Filtering signal ' num2str(k) ' in theta band...']);  
  [data, filtercmd] = process_eeg_filter( double(data), 'theta', eeg_signals(k).rate);
  
  %find_extremes (gradient method)
  verbosemsg('Finding extremes...')
  [peaks, troughs, zn, zp] = find_extremes(t, data, 'Method', 'gradient');
  
  %resample  
  [a,b] = rat( Fs_new ./ eeg_signals(k).rate );
  new_rate = eeg_signals(k).rate * a./b;
  verbosemsg(['Resampling to ' num2str(new_rate) 'Hz ...']);    
  data = resample( double(data), a, b );
  
  t = interp1( (1:numel(t))', t, 1+( 0:(numel(data)-1) )'.*b/a, 'linear', ...
               'extrap');
  %t = resample( t, a, b, []);
  
  %hilbert transform
  verbosemsg('Computing hilbert transform...');  
  h = hilbert( data );
  
  %save
  verbosemsg('Saving theta...')
  save_props( fullfile( rootdir, 'epochs', epoch, 'eeg' ), [eeg_signals(k).name '.signal'], ...
              struct('theta', struct('filtercmd', filtercmd, ...
                                     'extremes', struct( 'Fs', eeg_signals(k).rate, ...
                                                    'peaks', peaks, ...
                                                    'troughs', troughs, ...
                                                    'zeroneg', zn, ...
                                                    'zeropos', zp), ...
                                     'hilbert', struct( 'Fs', new_rate, ...
                                                    'transform', h, ...
                                                    'time', t) ...
                                     ) ...
                     ) ...
              );
  
end


