function [data, filtercmd] = process_eeg_filter( data, filtername, Fs)
%PROCESS_EEG_FILTER filter eeg data
%
%  [data,filtercmd]=PROCESS_EEG_FILTER(data,filtername,Fs)
%

if nargin<3
    help(mfilename)
    return
end

[b, filtercmd] = getfilter( Fs, filtername);

data = filtfilt( b, 1, data );
