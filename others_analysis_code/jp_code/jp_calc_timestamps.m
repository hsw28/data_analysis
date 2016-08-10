function ts = jp_calc_timestamps(tStart, tEnd, Fs)

ts = tStart: 1/Fs : tEnd + 1/Fs;

end