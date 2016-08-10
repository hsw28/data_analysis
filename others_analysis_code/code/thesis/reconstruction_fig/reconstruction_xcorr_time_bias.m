function b = reconstruction_xcorr_time_bias(rs)

nRows = size(rs,1);
nCols = size(rs,2);

midRow = floor((nRows+1)/2);
midCol = floor((nCols+1)/2);

b = sum(sum( rs(midRow+1:end, midCol+1:end) )) - ...
    sum(sum( rs(1:midRow-1,   1:midCol-1)   ));
