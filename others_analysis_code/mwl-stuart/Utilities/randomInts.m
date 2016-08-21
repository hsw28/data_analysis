function r = randomInts(V)

if ~isvector(V)
    error('V must be a vector');
end

maxV = max(V);

r = mod(randi(1e3 * maxV), V)+1;
    


end