function out = test_fn(x)
    t1 = 3500;
    t2 = 4500;
    out = cellfun(@within_time, x, 'UniformOutput',0);
    
    function valid = within_time(ts)
        valid = ts>=t1 & ts< t2;
    end
end