function idx = tholdFn(thold, len)

    if numel(thold)==1
        idx = len >= thold;
    else
        idx = len >= thold(1) & len <= thold(2);
    end

end