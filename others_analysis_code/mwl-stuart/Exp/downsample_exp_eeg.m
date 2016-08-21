function e = downsample_exp_eeg(e, fsNew)
    
    N = floor( e.fs / fsNew );
    
    e.data = downsample(e.data, N);
    e.ts = downsample(e.ts, N);
    e.fs = mean(diff(e.ts))^-1;

end