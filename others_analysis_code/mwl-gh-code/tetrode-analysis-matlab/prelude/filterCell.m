function newCell = filterCell( fun, oldCell )
% filter cell array accourding to predicate

newCell = oldCell( cellfun( fun, oldCell ) );