data = load_tt_peak_times('/data/spl11/day15', 'epoch', 'run');
%%
figure;
for i=1:numel(data)
    tt = data{i};
    plot(tt(:,1), tt(:,2),'r.');
    disp(i);
    pause;
end
%%

max = 0;
maxIdx = 0;
for i = 1:numel(data)
    if size(data{i},1)>max
        max = size(data{i},1);
        maxIdx = i;
    end
end

maxIdx = 4;

tt = data{maxIdx};

idx = logical(zeros(size(tt,1),1));
elTime = (tt(end,5)-tt(1,5))/60;
tt = tt(:,1:4);

thold = 5;
wb = my_waitbar(0);
newSpikes = zeros(size(tt));

vals = [];
for i = 1:size(idx)
    vals =  calcMinDistance(newSpikes', tt(i,:)');
    vals(i) = Inf;
    if (min(vals)>thold)
        newSpikes(i,:) = tt(i,:);
        idx(i) = 1;
    end
    
    wb = my_waitbar(i/numel(idx),wb);
end





plot(tt(:,1), tt(:,2), '.', 'markersize', 1); hold on; plot(newSpikes(:,1), newSpikes(:,2), 'r.', 'markersize', 1);
titleStr = [num2str(numel(idx)), ' original spikes ', num2str(sum(idx)), ' filtered spikes'];
title(titleStr);