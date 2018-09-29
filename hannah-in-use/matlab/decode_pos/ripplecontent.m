function f = ripplecontent(rippletimes, decoded)
%looks to see if decoding probability around ripples is >50%. returns ripples where this is the case
%works best for decoding at .02 seconds

decodedtime = decoded(4,:);
decodedprob = decoded(3,:);

contentripples = [];
for k=1:length(rippletimes)
    [c index] = min(abs(rippletimes(k)-decodedtime));
    indexprob = find(decodedprob(index:(index+4))>.3); %find probabilities over .5
    if indexprob >= 1 %probabilities are greater than 50% at least twice in 100ms
      contentripples(end+1) = rippletimes(k);
    end
end

f = contentripples;
