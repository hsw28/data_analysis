function r = mapReduce(r0, mapFn, redFn, xs)

r = r0;

for n = 1:numel(xs)
  r1 = mapFn(xs{n});
  r =  redFn(r,r1);
end
