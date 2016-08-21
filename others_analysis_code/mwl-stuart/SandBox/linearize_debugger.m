
figure;
p = sl06.run.position;
lp = p.lin_pos;
r_sample = randsample(numel(lp), 10000);
plot3(p.headpos(1,r_sample), p.headpos(2,r_sample), lp(r_sample), '.')
dist = 0:.25:max(lp);
c = 'yrcmyrcmyrcmyrcmyrcmyrcmyrcmyrcmyrcmyrcmyrcm';
hold on;
for i=1:length(dist)
    


    val = ~isnan(p.headpos(1,:)) & ~isnan(p.headpos(2,:));
    ind = lp>dist(i)-.01 & lp<dist(i)+.01;
    ind = ind & val;
    %plot3(p.headpos(1,ind), p.headpos(2,ind), lp(ind), [c(i),'*'] );
    
    val_ind = find(ind,1,'first');
    text(p.headpos(1,val_ind), p.headpos(2,val_ind), lp(val_ind), num2str(dist(i)), ...
        'fontsize', 20, 'FontWeight', 'Bold');
end
