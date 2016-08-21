function [pir, pcr, pis, pcs] = generateFigure1_ProbRippleDetect
%%
clear;
fprintf('Loading Sleep\n');
eList = dset_list_epochs('sleep');

[pIpsiSlp, pContSlp] = deal( nan(10,1) );
parfor iEpoch = 1:size(eList,1)
    
    fprintf('%d of %d\n', iEpoch, size(eList,1));
    d = [];
    if strcmp(eList{iEpoch, 1}, 'spl11')
        if strcmp( eList{iEpoch, 2}, 'day11')
            e = dset_exp_load_eeg('/data/spl11/day11', 'sleep2');
        else
            e = dset_exp_load_eeg('/data/spl11/day12', 'sleep3');
        end
        d.eeg = e;
    else
        d = dset_load_all(eList{iEpoch,:}, 'mu', 0);
    end
  
  
    [d] = dset_calc_ripple_times(d);
  
    win = d.ripples.chEventOnOffIdx;
    
    nTrig = size(win{1},1);
    pIpsiSlp(iEpoch) = nnz( inseg( win{2}, win{1}, 'partial' ) ) / nTrig;
    pContSlp(iEpoch) = nnz( inseg( win{3}, win{1}, 'partial' ) ) / nTrig;
    
end


[pIpsiRun, pContRun] = deal( nan(10,1) );

eList = dset_list_epochs('run');

fprintf('Loading Run\n');
parfor iEpoch = 1:size(eList,1)
    
    fprintf('%d of %d\n', iEpoch, size(eList,1));
    d = [];
    if strcmp(eList{iEpoch, 1}, 'spl11')
        if strcmp( eList{iEpoch, 2}, 'day11')
            e = dset_exp_load_eeg('/data/spl11/day11', 'run');
        else
            e = dset_exp_load_eeg('/data/spl11/day12', 'sleep2');
        end
        d.eeg = e;
    else
        d = dset_load_all(eList{iEpoch,:});
    end
    
    [d] = dset_calc_ripple_times(d);
  
    win = d.ripples.chEventOnOffIdx;
    
    nTrig = size(win{1},1);
    pIpsiRun(iEpoch) = nnz( inseg( win{2}, win{1}, 'partial' ) ) / nTrig;
    pContRun(iEpoch) = nnz( inseg( win{3}, win{1}, 'partial' ) ) / nTrig;
    
end
%%
pir = pIpsiRun; 
pcr = pContRun;
pis = pIpsiSlp;
pcs = pContSlp;

%%
data = [pIpsiRun, pContRun, pIpsiSlp, pContSlp] ;

f1 = figure; axes('NextPlot', 'add');

line( 1:2, data( :, 1:2), 'color', [.8 .8 .8]);
line( 3:4, data( :,  3:4), 'color', [.8 .8 .8]);

boxplot( data );


figName = 'Figure1_ProbRippleDetect';
save_bilat_figure(figName, f1);


set(gca,'XLim', [0 5], 'XTick', [1 2 3 4], 'XTickLabel', {'R:Ipsi', 'R:Cont', 'S:Ipsi', 'S:Cont'})


end