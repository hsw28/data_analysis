function [run sleep tbins] = dset_compute_bilateral_ripple_band_xcorr

plotting = 1;

eRun = dset_list_epochs('run');
eSleep = dset_list_epochs('sleep');

for i = 1:size(eRun,1)
    dset = dset_load_all(eRun{i,1}, eRun{i,2}, eRun{i,3});
    dset = dset_add_ref_to_eeg(dset);
    
    [xcIpsi(:,i) xcCont(:,i)] =  dset_analyze_xcorr_ripple_band(dset,1);
    if ~exist('eeg_fs', 'var')
        eeg_fs = dset.eeg(1).fs;
    end
end

run.xcIpsi = xcIpsi;
run.xcCont = xcCont;

%%
for i = 1:size(eSleep,1)
    dset = dset_load_all(eSleep{i,1}, eSleep{i,2}, eSleep{i,3});
    [xcIpsi(:,i) xcCont(:,i)] =  dset_analyze_xcorr_ripple_band(dset,1);
end

sleep.xcIpsi = xcIpsi;
sleep.xcCont = xcCont;

%%
if plotting==1
    xcContNRun = bsxfun(@rdivide, run.xcCont, sum(run.xcCont));
    xcIpsiNRun = bsxfun(@rdivide, run.xcIpsi, sum(run.xcIpsi));
    
    xcContNSleep = bsxfun(@rdivide, sleep.xcCont, sum(sleep.xcCont));
    xcIpsiNSleep = bsxfun(@rdivide, sleep.xcIpsi, sum(sleep.xcIpsi));

    tbins = 1:size(xcContNRun,1);
    tbins = tbins - ceil( tbins(end) / 2);
    tbins = tbins / eeg_fs;
    
    figure;
    subplot(211);
    plot(tbins, mean(xcContNRun,2),'r');
    hold on;
    plot(tbins, mean(xcIpsiNRun,2),'k');
    hold off;
    
    subplot(212);
    plot(tbins, mean(xcContNSleep,2),'r');
    hold on;
    plot(tbins, mean(xcIpsiNSleep,2),'k');
    hold off;
        
    legend({'Contralateral', 'Ipsilateral'});
end

end