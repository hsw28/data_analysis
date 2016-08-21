clear;
dlist = dset_list_epochs('run');

description = {};

for i = 1:size(dlist,1)
    
    description{i} = sprintf('%s %d %d\n', dlist{i,1}, dlist{i,2}, dlist{i,3});
    disp(['Ananlyzing ', description{i}]);
    dset = dset_load_all(dlist{i,1}, dlist{i,2}, dlist{i,3});
    pValsRun(i) = dset_analyze_bilateral_recon(dset);    
end

dlist = dset_list_epochs('sleep');

for i = 1:size(dlist,1);
    description{i} = sprintf('%s %d %d\n', dlist{i,1}, dlist{i,2}, dlist{i,3});
    disp(['Ananlyzing ', description{i}]);
    dset = dset_load_all(dlist{i,1}, dlist{i,2}, dlist{i,3});
    pValsSleep(i) = dset_analyze_bilateral_recon(dset);        
end