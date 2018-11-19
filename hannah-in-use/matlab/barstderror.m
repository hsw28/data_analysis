function f = barstderror(pop1, pop2)

figure
StdError1 = std(pop1)./sqrt(length(pop1));
StdError2 = std(pop2)./sqrt(length(pop2));
figure

errors = [StdError1, StdError2];
pops = [mean(pop1), mean(pop2)]

%barwitherr(StdError1, mean(pop1), StdError2, mean(pop2));
barwitherr(errors, (pops))
