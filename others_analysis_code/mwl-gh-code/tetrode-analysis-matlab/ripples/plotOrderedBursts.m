function f = plotOrderedBursts( b, arity, alignInd, epoch, behav )

bursts = reshape(getBurstsOfArity( b, arity ),[],1);
nBurst = numel(bursts);

colors =  cmap(@(x) [0.75,0.75,0.75], bursts);
burstTimes = cellfun(@(x) x(1), bursts);

isDuringRun = gh_points_are_in_segs(burstTimes, {epoch('run')});
colors( isDuringRun,: ) = mat2cell(repmat([0.6 0 0], sum(isDuringRun),1 ),ones(sum(isDuringRun),1),3);
isDuringSWS = gh_points_are_in_segs(burstTimes, behav('sws'));
colors( isDuringSWS,: ) = mat2cell(repmat([0 0.5 0], sum(isDuringSWS),1 ),ones(sum(isDuringSWS),1),3);

ord =orderOfBursts( b, arity );

colors = colors(ord,:);

alignedBursts = cmap( @(x) x - x(alignInd), bursts );

xs = cell2mat(alignedBursts(ord));
ys = repmat([1:length(xs)]',1,arity);

colors = cell2mat( cmap(@(x) repmat(x,arity,1), colors) );

scatter(reshape(xs',[],1),reshape(ys',[],1),[],colors,'filled');

xlabel('Ripple peak time (s)');
ylabel('Ripple Burst ID (sorted)'); 