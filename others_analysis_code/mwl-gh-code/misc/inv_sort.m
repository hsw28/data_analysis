function i = inv_sort(a,b)
% What are the indices into b that will give you a?

i = zeros(1,numel(a));

for n = 1:numel(a)
    i(n) = find(a(n) == b);
end