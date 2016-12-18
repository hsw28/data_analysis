function rate = powermap(powerdata,posData, lim)

% plot a heat map based on the power of the signal
% can also be used to heat map coherence, etc
%input powerdata and pos and your color limit (rec .55 for LS and .45 for HPC)

if size(powerdata,1)<size(powerdata,2)
	powerdata=powerdata';
end

dim = 3.5;

powerdata = powerdata';
tme = posData(:,1);
Power = assignvel(tme', powerdata);
Power = Power';

psize = 3.5 * dim; %some REAL ratio of pixels to cm
xmax = max(posData(:,2));
ymax = max(posData(:,3));
xbins = ceil(xmax/psize);
ybins = ceil(ymax/psize);
time = zeros(ybins,xbins);
events = zeros(ybins,xbins);
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
        avpower(ybins+1-j,i) = sum(Power(C))/sum(C); %set the matrix cell for that bin to the number of rows that satisfy both
    end
end

%heat map stuff
figure
[nr,nc] = size(avpower);
colormap('parula');
pcolor([(avpower) nan(nr,1); nan(1,nc+1)]);
shading flat;
set(gca, 'ydir', 'reverse');
set(gca,'clim',[0,lim]);
axis([16 (size(avpower, 2)+5) -4 (size(avpower,1))]);
colorbar;


