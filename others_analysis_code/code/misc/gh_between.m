function logicals = gh_between(x,bound)

logicals = and(x >= bound(1), x <= bound(2));