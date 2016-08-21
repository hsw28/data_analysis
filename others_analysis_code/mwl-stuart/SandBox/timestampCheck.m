function b = timestampCheck(ts)
epislon = 1e-9;

dt = diff(ts);
dt = dt - mean(dt);

b =  all(dt < epislon);
if (~b)
    error('Irregular timestamps detected. Off by%3.15f', max(dt));
end