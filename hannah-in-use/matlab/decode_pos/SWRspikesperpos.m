function f = SWRspikesperpos(decodedSWRpos, ripplespikes)

%from decodedSWRpos from POSdecodeSWRsegments.m, spikes from rippleLSspikes.m

if length(decodedSWRpos)~=length(ripplespikes)
 error('YOUR POS AND SPIKES ARENT THE SAME')
end



posses = posdistro(decodedSWRpos);
figure
if size(ripplespikes,1)>1 & size(ripplespikes,2)>1
  histedge = [1:1:max(ripplespikes(:))+1]
  nums = zeros(10,length(histedge)-1);
else
histedge = [1:1:max(ripplespikes)];
nums = zeros(10,length(histedge)-1);
end

for n=1:10
  subplot(5, 2, n);
  curQ = find((posses==n));
  if size(ripplespikes,1)>1 & size(ripplespikes,2)>1
    nums(n,:) = histcounts(ripplespikes(:,curQ), histedge);
    histogram((ripplespikes(:,curQ)));
    axis([0 max(ripplespikes(:))+1 0 max(histcounts(ripplespikes(:,curQ)))+5]);
  else
    nums(n,:) = histcounts(ripplespikes(curQ), histedge);
    histogram((ripplespikes(curQ)));
    axis([0 max(ripplespikes(:))+1 0 max(histcounts(ripplespikes(curQ)))+5]);
  end

  title(['Decoded Position ', num2str(n), ' '])
  ylabel('LS Spike Count')
  xlabel('LS Cell')

end

title(['Decoded Position ', num2str(n), ' '])
ylabel('LS Spike Count')
xlabel('LS Cell')
f = nums;

pall = [];
n1record = [];
n2record = [];
chart = NaN(10,10);
for n1=1:10
  for n2 = 10:-1:n1
    if n1==n2 | n2>n1;
      %[h,p,stats] = chi2ind(nums(n1,:), nums(n2,:));
      nums(n1,:);
      nums(n2,:);
      [h,p,stats] = chi2ind([nums(n1,:); nums(n2,:)]);
      pall(end+1) = p;
      chart(n1,n2) = p;
      n1record(end+1) = n1;
      n2record(end+1) = n2;

    end
  end
end

[h,p,stats] = chi2ind([nums]);
OVERALLp =p

figure
title('P Values from KS test')
heatmap(chart)


f = [pall', n1record', n2record'];


%[h,p] = kstest2(nums(1,:)+nums(4,:), nums(7,:)+nums(10,:));
figure
subplot(2,4,1)
[h,p,stats] = chi2ind([sum(nums([1,4],:),1); sum(nums([7,10],:),1)]);
b1 = (sum(nums([1,4],:),1))./sum((sum(nums([1,5],:),1)));
b2 = (sum(nums([7,10],:),1))./sum(sum(nums([7,10],:),1));
bar([b1; b2])
ylabel('Percent')
xlabel(['P value ', num2str(p)])
title('Unrewarded stopping (1,4) location vs rewarded (7,10))')

subplot(2,4,2)
[h,p,stats] = chi2ind([sum(nums([1,4,7,10],:),1); sum(nums([5,6],:),1)]);
b1 = (sum(nums([1,4,7,10],:),1))./sum((sum(nums([1,4,7,10],:),1)));
b2 = (sum(nums([5,6],:),1))./sum(sum(nums([5,6],:),1));
bar([b1; b2])
ylabel('Percent')
xlabel(['P value ', num2str(p)])
title('Stopping (1,4,7,10) vs Fast running (5,6)')

subplot(2,4,3)
[h,p,stats] = chi2ind([sum(nums([7,10],:),1); sum(nums([1,2,3,4,5,6,8,9],:),1)]);
b1 = (sum(nums([7,10],:),1))./sum((sum(nums([7,10],:),1)));
b2 = (sum(nums([1,2,3,4,5,6,8,9],:),1))./sum(sum(nums([1,2,3,4,5,6,8,9],:),1));
bar([b1; b2])
ylabel('Percent')
xlabel(['P value ', num2str(p)])
title('Reward point (7,10) vs Other (1,2,3,4,5,6,8,9)')

subplot(2,4,4)
[h,p,stats] = chi2ind([sum(nums([7,10],:),1); sum(nums([8,9],:),1)]);
b1 = (sum(nums([7,10],:),1))./sum((sum(nums([7,10],:),1)));
b2 = (sum(nums([8,9],:),1))./sum(sum(nums([8,9],:),1));
bar([b1; b2])
ylabel('Percent')
xlabel(['P value ', num2str(p)])
title('Reward point (7,10) vs Reward approach (8,9)')

subplot(2,4,5)
[h,p,stats] = chi2ind([sum(nums([7:10],:),1); sum(nums([1:4],:),1)]);
b1 = (sum(nums([7:10],:),1))./sum((sum(nums([7:10],:),1)));
b2 = (sum(nums([1:4],:),1))./sum(sum(nums([1:4],:),1));
bar([b1; b2])
ylabel('Percent')
xlabel(['P value ', num2str(p)])
title('Choice/rewarded arms (7:10) vs Forced arms (1:4)')

subplot(2,4,6)
[h,p,stats] = chi2ind([sum(nums([1,4,7,10],:),1); sum(nums([2,3,5,6,8,9],:),1)]);
b1 = (sum(nums([1,4,7,10],:),1))./sum((sum(nums([1,4,7,10],:),1)));
b2 = (sum(nums([2,3,5,6,8,9],:),1))./sum(sum(nums([2,3,5,6,8,9],:),1));
bar([b1; b2])
ylabel('Percent')
xlabel(['P value ', num2str(p)])
title('Stopping (1,4,7,10) vs Running (2,3,5,6,8,9)')

subplot(2,4,7)
[h,p,stats] = chi2ind([sum(nums([7:10],:),1); sum(nums([1:6],:),1)]);
b1 = (sum(nums([7:10],:),1))./sum((sum(nums([7:10],:),1)));
b2 = (sum(nums([1:6],:),1))./sum(sum(nums([1:6],:),1));
bar([b1; b2])
ylabel('Percent ')
xlabel(['P value ', num2str(p)])
title('Rewarded arms (7:10) vs Rest (1:6)')

subplot(2,4,8)
[h,p,stats] = chi2ind([sum(nums([1,4],:),1); sum(nums([2,3],:),1)]);
b1 = (sum(nums([1,4],:),1))./sum((sum(nums([1,4],:),1)));
b2 = (sum(nums([2,3],:),1))./sum(sum(nums([2,3],:),1));
bar([b1; b2])
ylabel('Percent ')
xlabel(['P value ', num2str(p)])
title('Forced end (1,4) vs Forced end approach (2,3)')



%p
