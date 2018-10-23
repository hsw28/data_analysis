function f = hdvelocity(headdirection)

times = headdirection(1,:);
hd = headdirection(2,:);

hdvel = diff(hd);

f = [hdvel; times(1:end-1)];
