function r = shuffledStats(vel,units,lfp,time,criteria,num)
%     vels = velocity(pos);
%     vel = vels;
%     units = mazet21c1*7.75e-2;
%     lfp = lfpmaze19.data;
%     time = lfpmaze19.timestamp*7.75e-2;
%     criteria = 5000;
    set(0,'DefaultFigureVisible', 'off');
    maxVals = zeros([num 1]);
    minVals = maxVals;
    for i = 1:num
        s = isiShuffle(vel,units,time,criteria);
        f = STA(s,lfp,time,1);
        maxVals(i) = max(f);
        minVals(i) = min(f);
    end
    maxVals = sort(maxVals);
    minVals = sort(minVals,'descend');
    r = [maxVals, minVals];
    max(maxVals)
    min(minVals)