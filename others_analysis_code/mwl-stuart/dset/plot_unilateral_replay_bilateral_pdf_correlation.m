function plot_unilateral_replay_bilateral_pdf_correlation(corrData)

for i = 1:numel(corrData)
    
    data = corrData(i);


    figure('Name', data.description); 

    subplot(211);    
    bins = -1:.05:1;
    hist(data.replayCorr, bins);

    subplot(212);
    mCorr = mean(data.replayCorr);
    mShuf = mean(data.shuffleCorr);

    hist(mShuf);
    yLim = get(gca,'YLim');
    line([mCorr, mCorr], yLim);
    
end


end