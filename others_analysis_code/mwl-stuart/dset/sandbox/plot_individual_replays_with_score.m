dset = dset_load_all('Bon', 4, 4);
%%
[s r] = dset_calc_replay_stats(dset, [], [], [], 0);
%%
% s = sleep.stats.B;
% r = sleep.recon.B;
s = st(2);
r = re(2);
d = dset;
%%
pfEdges = d.clusters(1).pf_edges;
% left traj
pIdx{1} =  [pfEdges(1,1):pfEdges(1,2), pfEdges(2,1):pfEdges(2,2)];
% right traj
pIdx{2} = [pfEdges(1,1):pfEdges(1,2), pfEdges(3,1):pfEdges(3,2)];
% out traj
pIdx{3} =   [fliplr(pfEdges(2,1) : pfEdges(2,2)), pfEdges(3,1):pfEdges(3,2) ] ;

%%
f = figure('Position', [2466 62 444 818]);
a(1) = subplot(311);
a(2) = subplot(312);
a(3) = subplot(313);

[~, idx] = max(s.score2,[],2);

calcScore = zeros(size(s.score2));
for i = 1:size(d.mu.bursts,1)
 
    tempIdx = r.tbins >= d.mu.bursts(i,1) & r.tbins <= d.mu.bursts(i,2);

    slope = s.slope(i,:);
    inter = s.intercept(i, :);
    score = s.score2(i,:);
    for j = 1:3
        
        imagesc(r.tbins(tempIdx), r.pbins{j}, r.pdf{j}(:,tempIdx), 'Parent', a(j));
        yPts = slope(j) * r.tbins(tempIdx) + inter(j);
        line(r.tbins(tempIdx), yPts, 'color', 'w', 'Parent', a(j), 'linewidth', 2, 'linestyle', '--');
        
        calcScore(i,j) = compute_line_score(r.tbins(tempIdx), r.pbins{j}, r.pdf{j}(:,tempIdx), slope(j), inter(j));
        
       
    end
    pause;
end

%%
s(1) = stats.L;
s(2) = stats.R;
r(1) = recon.L;
r(2) = recon.R;

%%
f = figure('Position', [2466 62 888 818]);

a(1) = subplot(321);
a(2) = subplot(322);
a(3) = subplot(323);

a(4) = subplot(324);
a(5) = subplot(325);
a(6) = subplot(326);

[~, idx] = max(s(1).score2,[],2);

calcScore = zeros(size(s(1).score2));
for i = 1:size(d.mu.bursts,1)
 disp(i);
    tempIdx = r(1).tbins >= d.mu.bursts(i,1) & r(1).tbins <= d.mu.bursts(i,2);

    for k = 1:2
        slope = s(k).slope(i,:);
        inter = s(k).intercept(i, :);
        score = s(k).score2(i,:);
        for j = 1:3
            imagesc(r(k).tbins(tempIdx), r(k).pbins{j}, r(k).pdf{j}(:,tempIdx), 'Parent', a(j + (k-1)*3));
            yPts = slope(j) * r(k).tbins(tempIdx) + inter(j);
            line(r(k).tbins(tempIdx), yPts, 'color', 'w', 'Parent', a(j + (k-1)*3), 'linewidth', 2, 'linestyle', '--');
            title(num2str(slope(j)), 'Parent', a(j + (k-1) * 3);
        end
    end
    pause;
end

