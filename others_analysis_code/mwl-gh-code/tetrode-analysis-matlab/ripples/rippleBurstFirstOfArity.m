function ts = rippleBurstFirstOfArity(bursts, arity)

% Make sure row number still corresponds to arity
wantedBursts = bursts{arity};
assert(numel(wantedBursts{1}) == arity);

ts = cellfun(@(x) x(1), bursts{arity});