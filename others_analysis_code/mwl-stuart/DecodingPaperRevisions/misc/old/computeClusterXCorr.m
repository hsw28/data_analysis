function [xc] = computeClusterXcorr(baseDir, iTetrode)

[cl, data, ttList] = load_clusters_for_day(baseDir);
nTT = numel(cl);

if nargin==1
	ttList = 1:nTT
end

if nTT < iTetrode
	xc = [];
	fprintf('Invalid tetrode number: %d\n', iTetrode);
	return
end

fprintf('Evaluating TT:%d\n', iTetrode);

clId = cl{iTetrode};
ts = data{iTetrode};

nCl = max(clId);

dt = .001;
nLag = 50;
if nCl < 2

    xc = [];

else

	%Pre compute the timebin range
	tRange = cell2mat( cellfun(@(x) (minmax(x(:,5)')), data, 'uniformoutput', 0)' );
	tbins = min(tRange(:,1)) :dt: max(tRange(:,2));

	%Pre compute the spike rate for each cluster
	fprintf('Computing rates:');
	rate = zeros(nCl, numel(tbins));
	for iCl = 1:nCl
	    rate(iCl,:) = histc( data{iTetrode}(clId == iCl,5), tbins );
	    fprintf('%d ', iCl);
	end
	fprintf('\n');

	% Precompute the xcorr spike rates
	fprintf('Computing xcorr:');

	xc = nan(nCl * nCl, nLag *2 + 1);

	parfor iCl = 1:(nCl * nCl)
	         
	    ii = ceil( iCl / nCl);
	    jj = mod( iCl - 1,  nCl) + 1;

	    xc(iCl,:) = xcorr(rate(ii,:), rate(jj,:), nLag);        
	   
	end

	% Delete the 0 lag value correlations
	xc(:,nLag + 1) = 0;

	% xc = reshape(xc, [nCl, nCl, nLag *2 + 1]);
	fprintf('\n');

end

xcFile = sprintf('%s/kKlust/xcorr_%s.mat', baseDir, ttList{iTetrode} );
fprintf('Saving file %s\n', xcFile);
save( xcFile, 'xc');