%DEPRECATED

function f = movingcorr(lfp, windowlength)

%window length is in time points

len=length(lfp);
%nwin = floor(len./windowlength);
nwin = windowlength;
moving_window = [1:nwin]';

noverlap=floor(0.9*nwin);

%amount not yet covdred / window
k=floor((len-noverlap)/(nwin-noverlap));

cor = [];
j = 1;
q = 1;
index=1:nwin;
indextwo = 1:nwin;

while j<=k & indextwo(end) <= len-nwin
	q = 1;
	index=1:nwin;
	while q<=k & index(end) <= len-nwin
		cr=xcorr(lfp(index)-mean(lfp(index)),lfp(indextwo)-mean(lfp(indextwo)), 'coeff');
		cor(j, q) = mean(cr); 	% do you average? do you take the peak? NO ONE KNOWS
      		index=index+(nwin-noverlap);
		q=q+1;
	end
indextwo=indextwo+(nwin-noverlap);
j=j+1;
end

f=cor;
heatmap(cor);
