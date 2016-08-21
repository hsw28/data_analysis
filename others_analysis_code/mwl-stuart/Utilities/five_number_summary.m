function sum = five_number_summary(vector)
vector = sort(vector);
sum = nan(5,1);
sum(1) = min(vector);
sum(5) = max(vector);
sum(3) = median(vector);
l = floor(length(vector)/4);
sum(2) = vector(l);
sum(4) = vector(end-l);

