function generateFigure5_examples

%%

rDayList = [11, 12, 13, 14];
sDayList = [11, 12, 15];

rEvList  = {[59, 85,107,126], [72, 94, 99], [64,190, 203], 150 };    
sEvList = { [471, 525, 579,  826, 969, 1078], [34, 38, 115, 188, 250], [4, 48, 275, 289] };   

N = numel(rDayList);

for j = 1:N
    ep = 'run';
    clear d b rIdx lIdx r
    d = dset_load_all('spl11', rDayList(j), ep);
    b = d.mu.bursts;

    lIdx = strcmp( {d.clusters.hemisphere},'left');
    rIdx = strcmp( {d.clusters.hemisphere},'right');
 
    evList = rEvList{j};
    n = numel(evList);
 
    tau = .02;
    ts = d.epochTime(1):.02:d.epochTime(2);
    for i = 1:n
       
        eIdx = evList(i);
        win = interp1(ts, ts, b(eIdx,:), 'nearest');
        
        
        r(1) = dset_reconstruct( d.clusters(lIdx), 'tau', tau, 'time_win', win);
        r(2) = dset_reconstruct( d.clusters(rIdx), 'tau', tau, 'time_win', win );
        
        noSpk1 = sum( r(1).spike_counts ) == 0;
        noSpk2 = sum( r(2).spike_counts ) == 0;
        
        t = 1:numel( r(1).tbins ) * 20;
        p = r(1).pbins;
       
        
        pdf1 = normc( r(1).pdf );
        pdf2 = normc( r(2).pdf );
        
        
        pdf1(:, noSpk1) = 0;
        pdf2(:, noSpk2) = 0;
        
        pdf1 = 1 - repmat(pdf1, [1 1 3]);
        pdf2 = 1 - repmat(pdf2, [1 1 3]);
        
        pdf1 = imresize(pdf1, 5, 'nearest');
        pdf2 = imresize(pdf2, 5, 'nearest');   
        
         basePath = '/data/bilateral/figures/Fig5Examples/';
        baseName = 'Fig5_Example_spll11_d%d_%s_%d_%s.png';

        lName = fullfile(basePath, sprintf(baseName, rDayList(j), ep, eIdx, 'L'));
        rName = fullfile(basePath, sprintf(baseName, rDayList(j), ep, eIdx, 'R'));

        imwrite(pdf1, lName, 'png');
        imwrite(pdf2, rName, 'png');
 
        fprintf('Example %d for SPL11 D%d saved!\n', i, rDayList(j));
        
    end
     
end  

N = numel(sDayList);

for j = 1:N
    ep = 'sleep';
    clear d b rIdx lIdx r
    d = dset_load_all('spl11', sDayList(j), ep);
    b = d.mu.bursts;

    lIdx = strcmp( {d.clusters.hemisphere},'left');
    rIdx = strcmp( {d.clusters.hemisphere},'right');
 
    evList = sEvList{j};
    n = numel(evList);
 
    tau = .02;
    ts = d.epochTime(1):.02:d.epochTime(2);
    for i = 1:n
       
        eIdx = evList(i);
        win = interp1(ts, ts, b(eIdx,:), 'nearest');
        
        
        r(1) = dset_reconstruct( d.clusters(lIdx), 'tau', tau, 'time_win', win);
        r(2) = dset_reconstruct( d.clusters(rIdx), 'tau', tau, 'time_win', win );
        
        noSpk1 = sum( r(1).spike_counts ) == 0;
        noSpk2 = sum( r(2).spike_counts ) == 0;
        
        t = 1:numel( r(1).tbins ) * 20;
        p = r(1).pbins;
       
        
        pdf1 = normc( r(1).pdf );
        pdf2 = normc( r(2).pdf );
        
        
        pdf1(:, noSpk1) = 0;
        pdf2(:, noSpk2) = 0;
        
        pdf1 = 1 - repmat(pdf1, [1 1 3]);
        pdf2 = 1 - repmat(pdf2, [1 1 3]);
        
        pdf1 = imresize(pdf1, 5, 'nearest');
        pdf2 = imresize(pdf2, 5, 'nearest');   
        
        basePath = '/data/bilateral/figures/Fig5Examples/';
        baseName = 'Fig5_Example_spll11_d%d_%s_%d_%s.png';

        lName = fullfile(basePath, sprintf(baseName, rDayList(j), ep, eIdx, 'L'));
        rName = fullfile(basePath, sprintf(baseName, rDayList(j), ep, eIdx, 'R'));

        imwrite(pdf1, lName, 'png');
        imwrite(pdf2, rName, 'png');
 
        fprintf('Example %d for SPL11 D%d saved!\n', i, rDayList(j));
    end
     
end 

f = figure; 
imagesc( t, p, pdf1);

save_bilat_figure('Fig5Example', f, 1);
close(f)

end