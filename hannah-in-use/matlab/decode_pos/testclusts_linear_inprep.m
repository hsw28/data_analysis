function f = testclusts_linear_inprep(time, pos, clusters, tdecode, dim)

clustname = (fieldnames(clusters));
numclust = length(clustname);
clustlist = [1:1:numclust];

output = {'cluster name'; 'mean'; 'median'; 'linear_mean'; 'linear_median'};


purepos = pos;
velthreshold = 12;


posData = pos;
posData = fixpos(posData);

tdecodesec = tdecode;

size(pos);
timevector =time;
vel = velocity(posData);
vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
goodvel = find(vel>=velthreshold);
pos = posData(find(goodvel<length(posData)),:);  %pos is only fast vels


x = pos(:,2);
y = pos(:,3);
bound = boundary(x,y);
xbound = x(bound);
ybound = y(bound); %these are the outline coordinates

%FOR LEFT COLUMN
lleftbound = min(xbound); %leftbound
%rightbound
ytemp = find(ybound>410 | ybound<310);
xtemp = find(xbound<550);
xtemp = intersect(xtemp, ytemp);
lrightbound = max(xbound(xtemp)); %rightbound
%topbound
xtemp = find(xbound<520);
ltopbound = max(ybound(xtemp)); %topbound
%bottombound
xtemp = find(xbound<520);
lbottombound = min(ybound(xtemp)); %topbound
%bounds on left arm: lleftbound, lrightbound, ltopbound, lbottombound

%FOR RIGHT COLUMN
rrightbound = max(xbound); %rightbound
%leftbound
ytemp = find(ybound>420 | ybound<320);
xtemp = find(xbound>800);
xtemp = intersect(xtemp, ytemp);
rleftbound = max(xbound(xtemp)); %rightbound
%topbound
xtemp = find(xbound>740);
rtopbound = max(ybound(xtemp)); %topbound
%bottombound
xtemp = find(xbound>740);
rbottombound = min(ybound(xtemp)); %topbound
%bounds on left arm: rleftbound, rrightbound, rtopbound, rbottombound

%FOR MIDDLE
%is between lrightbound and rleftbound
xtemp = find(xbound>lrightbound & xbound<rrightbound);
mtopbound = max(ybound(xtemp));
mbottombound = min(ybound(xtemp));
mleftbound = lrightbound;
mrightbound = rleftbound;
%bounds on bottom: mleftbound, mrightbound, mtopbound, mbottombound

%BIN
psize = 3.5 * dim;

%want to make a vector of all the increments
%LEFT ARM
bottomvec = [];
topvec = [];
for lb = 0:floor((ltopbound-lbottombound)./psize)
  bottomvec(end+1) = lbottombound+(lb*psize);
  topvec(end+1) = lbottombound+((lb+1)*psize);
end
leftvectemp1 = ones((length(bottomvec)),1)*lleftbound;
leftvectemp2 = ones((length(bottomvec)),1)*lrightbound;
leftvect = [leftvectemp1, leftvectemp2, bottomvec', topvec']; %LEFT ARM

%right ARM
bottomvec = [];
topvec = [];
for rb = 0:floor((rtopbound-rbottombound)./psize)
  bottomvec(end+1) = rbottombound+(rb*psize);
  topvec(end+1) = rbottombound+((rb+1)*psize);
end
rightvectemp1 = ones((length(bottomvec)),1)*rleftbound;
rightvectemp2 = ones((length(bottomvec)),1)*rrightbound;
rightvect = [rightvectemp1, rightvectemp2, bottomvec', topvec']; %RIGHT ARM
%MIDDLE ARM
leftvec = [];
rightvec = [];
for rb = 0:floor((mrightbound-mleftbound)./psize)
  leftvec(end+1) = mleftbound+(rb*psize);
  rightvec(end+1) = mleftbound+((rb+1)*psize);
end
topvectemp1 = ones((length(leftvec)),1)*mtopbound;
bottomvectemp2 = ones((length(leftvec)),1)*mbottombound;
midvect = [leftvec', rightvec', bottomvectemp2, topvectemp1]; %MIDDLE ARM

allvec = [leftvect; rightvect; midvect]; %dimesions are [n, 4]


% for each cluster,find the firing rate at esch velocity range
%firingPerPos_linear(posData, clusters, tdecode, pos_samp_per_sec, bounds, varargin)
fxmatrix = firingPerPos_linear(posData, clusters, tdecodesec, 30, allvec, velthreshold);
names = (fieldnames(fxmatrix));
for k=1:length(names)
  curname = char(names(k));
  %fxmatrix.(curname) = chartinterp(fxmatrix.(curname));
  fxmatrix.(curname) = ndnanfilter(fxmatrix.(curname), 'gausswin', [dim*2/dim, dim*2/dim], 2, {}, {'replicate'}, 1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%

for k = 1:numclust
  ridname = clustname(k)

  newfx = struct;
  for c=1:numclust
      name = char(clustname(c));
      l1 = strlength(char(ridname));
      l2 = strlength(name);
      if l1 < l2
        con = contains(char(ridname),name);
      else
        con = contains(name, char(ridname));
      end
      if con == 0
        newfx.(name) = (fxmatrix.(name));
      else
        fprintf('match')
      end
    end



  newclusts = rmfield(clusters,char(ridname));

  [decoded allvec] = test_decodeshitPos_linear(time, purepos, newclusts, tdecode, dim, newfx);
  %error
  error = decodederror(decoded, pos, tdecode);
  error_av = nanmean(error(1,:));
  error_med = nanmedian(error(1,:));

  error = decodederror_linear(decoded, pos, tdecode, allvec);
  error_lin_av = nanmean(error(1,:));
  error_lin_med = nanmedian(error(1,:));

  newdata = {ridname; error_av; error_med; error_lin_av; error_lin_med};
  output = horzcat(output, newdata);
  numclust-k
end

f = output';
