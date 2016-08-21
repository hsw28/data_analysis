function fs = timestamp2fs(ts)


if ~timestampCheck(ts)
    error('Irregular timestamps');
end


fs = 1 / ( ts(2) - ts(1) );