
%%
s = load(mwlopen('/data/spl11/day15/t08/t08.filtered.pxyabw'));
b = load(mwlopen('/data/spl11/day15/t08/cbtest'));

%%
figure('position', [350 250 1200 850]);

axes('Position', [.05 .05 .9 .9], 'color', 'k');
line(s.t_px, s.t_py, 'linestyle', 'none', 'marker', '.', 'color', 'w', 'markersize', 1);

v = b(1).bounds.vertices;
line(v(:,1), v(:,2), 'color', 'y');

v = b(2).bounds.vertices;
line(v(:,1), v(:,2), 'color', 'm');

v = b(3).bounds.vertices;
line(v(:,1), v(:,2), 'color', 'g');


%%

posEst = pos_pdf_to_pos_estimate(pospdf,input.exp.(ep).pos);

posRec = interp1(p.ts, p.lp, output.tbins, 'nearest');
posRec(isnan(posRec)) = 0;
posRec = floor(posRec*10)/10;
velRec = interp1(p.ts, p.lv, output.tbins, 'nearest');
velRec(isnan(velRec)) = 0;

isMoving = abs(velRec)>.1;
%%
idx = find(isMoving);

mu = [];
for c = 1:1000
    rand_idx = randsample(idx,floor(numel(idx)*.8));
    for i=1:numel(posEst)
        mu(i).dist(c) = mutualinfo(posEst{i}(rand_idx), posRec(rand_idx));
        mu(i).val = mutualinfo(posEst{i}(idx), posRec(idx));
    end
end
%%
[mi mi_dist] = calc_recon_mi(output.est, output.tbins, input.exp.run.pos, 'n_boot',2);
%%
[ers me me_dist] = calc_recon_errors(output.est, output.tbins, input.exp.run.pos, 'nboot', 2);
%%
[co co_dist] = calc_recon_corr2(output.est, output.tbins, input.exp.run.pos, 'nboot', 2);
%%
figure; 
subplot(311); line(1:5, cell2mat(mi), 'color', 'r', 'linestyle', 'none', 'marker', '*'); 
title('Mutual Information'); set(gca,'XTick', [1:5], 'XTickLabel', input.method);
subplot(312); line(1:5, cell2mat(me), 'color', 'k', 'linestyle', 'none', 'marker', '*');
title('Median Error'); set(gca,'XTick', [1:5], 'XTickLabel', input.method);
subplot(313); line(1:5, cell2mat(co), 'color', 'b', 'linestyle', 'none', 'marker', '*');
title('2D Corr'); set(gca,'XTick', [1:5], 'XTickLabel', input.method);

%%
bins = .8:.005:1.3;
figure;
c = 'rgbck';
for i=1:numel(mu)
    line(bins, smoothn(histc(mu(i).dist,bins),3), 'color', c(i), 'linewidth', 2);
    line([mu(i).val mu(i).val], [72 62], 'color', c(i), 'linewidth', 2, 'HandleVisibility','off');
end

legend(input.method, 'location', 'southwest')