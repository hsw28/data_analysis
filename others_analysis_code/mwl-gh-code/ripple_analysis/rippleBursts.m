function bursts = rippleBursts(ripples, varargin)

p = inputParser();
p.addParamValue('tThresh',0.25);
p.parse(varargin{:})
opt = p.Results;

maxBurstArity = 10;
withinBurst = 0;
arity = 0;

bursts = cell(1,maxBurstArity);

rippleM = cell2mat(ripples);
rippleIntervals = [diff(rippleM(:,1))', Inf];

for n = 1:numel(ripples)
    
    if(~withinBurst)
        arity = 1;
        firstInBurst = n;
    else
        arity = arity + 1;
    end
    
    if(rippleIntervals(n) > opt.tThresh)
        lastInBurst = n;
        arityCell = bursts{arity};
        arityCell{numel(arityCell)+1} = ripples(firstInBurst:lastInBurst);
        bursts{arity} = arityCell;
        withinBurst = 0;
    else
        withinBurst = 1;
    end

end
    
    