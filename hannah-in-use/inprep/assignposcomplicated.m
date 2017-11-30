function ap = assignpos(time, pos);

% assigns position to all timepoints
% input time vector and position
% ap = assignpos(time, pos)

xcord = [pos(:,2), pos(:,1)];
xcord = xcord';
ycord = [pos(:,3), pos(:,1)];
ycord = ycord';

%have to do it in chunks for unique values
size(xcord)
u = unique(xcord(1,:));
[n,bin]=histc(xcord(1,:),u);
ix1=find(n>1);
i = 1;
x = [];
while i<=length(ix1)
    if i == 1
        ix1(i)
        xcord = assignvel(time, xcord(:, 1:ix1(i)));
    elseif i<length(u)
        xcord = assignvel(time, xcord(:, ix1(i-1):ix1(i)));
    elseif i==length(u)
        xcord = assignvel(time, xcord(:, ix1(i-1):end));
    end
xcord;
x = [x,xcord];
size(x);
i = i+1
end

%now for y
size(ycord)
u = unique(ycord(1,:));
[n,bin]=histc(ycord(1,:),u);
ix1=find(n>1);
i = 1
x = [];
while i<=length(ix1)
    if i == 1
        ycord = assignvel(time, ycord(:, 1:ix1(i)));
    elseif i<length(u)
        ycord = assignvel(time, ycord(:, ix1(i-1):ix1(i)));
    elseif i==length(u)
        ycord = assignvel(time, ycord(:, ix1(i-1):end));
    end
x = combine(x,xcord)
i = i+1;
end



time = time(1:length(x));
p = [time; x; y];
ap = p';
