function R=test_replay_nclusters(E, segs, select)


nclusters=[5 10 15 20 25 30];
ndraws=20;

nshuffle=100;

spikes = E.defaultspikes;
nspikes = numel(spikes);
nk=0;

for k=nclusters
  nk=nk+1;
  for j=1:ndraws
    
    E.defaultspikes = {spikes( randsample(nspikes,k) )};
    
    R(j,nk)=analyze_replay_final(E, segs, 'smooth', 1, 'smooth_sd', [20 0 0], 'noshuffle', 1, 'shufflecycle', nshuffle, 'shuffleclperm', nshuffle, 'shufflepseudo', 0, 'select', select, 'pad', 1, 'radonmethod','logsum');
    
  end
end