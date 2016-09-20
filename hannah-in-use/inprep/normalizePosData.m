function rate = normalizePosData(posData,eventData,size)

%This function takes a position data set with columns [time,x,y] and a bin
%size in cm as arguments then outputs a matrix with entries that represent the
%number of time instances in each bin
%only square bins are supported
psize = 6.3 * size; %some made up ratio of pixels to cm
xmax = max(posData(:,2));
ymax = max(posData(:,3));
xbins = ceil(xmax/psize);
ybins = ceil(ymax/psize);
time = zeros(xbins,ybins);
events = zeros(xbins,ybins);
xstep = xmax/xbins;
ystep = ymax/ybins;
tstep = 1/30;
for i = 1:xbins
    for j = 1:ybins
        A1 = posData(:,2)>((i-1)*xstep) & posData(:,2)<=(i*xstep); %finds all rows that are in the current x axis bin
        A2 = posData(:,3)>((j-1)*ystep) & posData(:,3)<=(j*ystep); %finds all rows that are in the current y axis bin
        A = [A1 A2]; %merge results
        B = sum(A,2); %find the rows that satisfy both previous conditions
        C = B > 1;
        time(ybins+1-j,i) = sum(C); %set the matrix cell for that bin to the number of rows that satisfy both
    end
end

for i = 1:xbins
    for j = 1:ybins
        A1 = eventData(:,2)>((i-1)*xstep) & eventData(:,2)<=(i*xstep); %finds all rows that are in the current x axis bin
        A2 = eventData(:,3)>((j-1)*ystep) & eventData(:,3)<=(j*ystep); %finds all rows that are in the current y axis bin
        A = [A1 A2]; %merge results
        B = sum(A,2); %find the rows that satisfy both previous conditions
        C = B > 1;
        events(ybins+1-j,i) = sum(C); %set the matrix cell for that bin to the number of rows that satisfy both
    end
end

rate = events./(time*tstep);