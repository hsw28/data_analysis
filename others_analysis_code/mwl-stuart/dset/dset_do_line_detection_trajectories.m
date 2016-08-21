function stats = dset_do_line_detection(dset, p)
    
if ~isfield(dset,'mu') || ~isfield(dset.mu, 'bursts')
    error('No multi unit burst data');
end

bursts = dset.mu.bursts;

dt = mean(diff(p.tbins'));

for t = 1:numel(p.pbins)
    for i = 1:size(bursts,1)
        tsIdx(1) = interp1(p.tbins(:,1), 1:size(p.tbins,1), bursts(i,1), 'nearest');
        tsIdx(2) = interp1(p.tbins(:,1), 1:size(p.tbins,1), bursts(i,2), 'nearest');

        idx = tsIdx(1):tsIdx(2);
        tbins = p.tbins(idx);
        pbins = p.pbins{t};

        [~, ~, score(t,i), ~] = est_line_detect(tbins, pbins, p.all{t}(:,idx)); 
    end
end

stats.score = score;