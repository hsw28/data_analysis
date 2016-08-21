function rhil = calculate_ave_hilbert(exp)
% computes the average hilbert transform for each LFP trace under each
% epoch and returns the single average

for e = exp.epochs
    e = e{1};
    f = getfilter(exp.(e).eeg(1).fs, 'ripple', 'win');
    ripple = single(nan(length(exp.(e).eeg), length(exp.(e).eeg(1).data)));
    for i=1:length(exp.(e).eeg)
        disp(['Filtering ' , e, ' trace:', num2str(i)]);
        ripple(i,:) = filtfilt(f, 1, exp.(e).eeg(i).data);
    end
    disp('Computing the average hilbert');
    
    valid_chan = logical(1:size(ripple,1));
    valid_chan(isnan(mean(ripple,2))) = 0;
    ripple = ripple(valid_chan,:);
    rhil.(e) = abs(mean(hilbert(ripple)));  
end

end
