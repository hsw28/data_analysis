function a = getBurstsOfArity(b,arity)

a = b{arity};

% make sure that the arity lines up with cell array index.
assert(numel(a{1}) == arity);