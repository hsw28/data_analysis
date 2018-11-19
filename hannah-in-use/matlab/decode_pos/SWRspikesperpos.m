function f = SWRspikesperpos(decodedSWRpos, ripplespikes)

%from decodedSWRpos from POSdecodeSWRsegments.m, spikes from rippleLSspikes.m

if length(decodedSWRpos)~=length(ripplespikes)
 error('YOUR POS AND SPIKES ARENT THE SAME')
end



posses = posdistro(decodedSWRpos);
figure
for n=1:10
  subplot(5, 2, n);
  curQ = find((posses==n));
  length(curQ)
  histogram((ripplespikes(:,curQ)));
  title(['Decoded Position ', num2str(n), ' '])
  ylabel('LS Spike Count')
  xlabel('LS Cell')
  axis([0 max(ripplespikes(:))+1 0 max(histcounts(ripplespikes(:,curQ)))+5]);
end
