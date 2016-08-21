function s = summ(s)

while ~isscalar(s)
    s = sum(s);
end