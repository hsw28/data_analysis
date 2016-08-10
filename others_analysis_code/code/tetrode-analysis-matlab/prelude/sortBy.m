function outCA = sortBy(pred, inCA)

[~,ind] = sort( cellfun(@(x) pred(x), inCA) );
outCA = inCA(ind);