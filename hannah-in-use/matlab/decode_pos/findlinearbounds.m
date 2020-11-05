function [allvec lefttop leftchoice leftbottom middleall righttop rightchoice rightbottom] = findlinearbounds(pos)
%finds linear bounds with 8 dvisions for eeach segment of the left and right arms and 11 for middle stem
%TAKES FIXED POS DATA


[x,TF] = rmoutliers(pos(:,2), 'movmean', 30);
xgood = setdiff([1:length(pos(:,2))], TF);
[y,TF] = rmoutliers(pos(:,3), 'movmean', 30);
ygood = setdiff([1:length(pos(:,3))], TF);
allgood = intersect(xgood,ygood);
x = pos(allgood,2);
y = pos(allgood,3);
bound = boundary(x,y);
xbound = x(bound);
ybound = y(bound); %these are the outline coordinates

%FOR LEFT COLUMN
lleftbound = min(xbound); %leftbound
%rightbound
ytemp = find(ybound>410 | ybound<310);
xtemp = find(xbound<550);
xtemp = intersect(xtemp, ytemp);
lrightbound = max(xbound(xtemp))+eps; %rightbound
%topbound
xtemp = find(xbound<520);
ltopbound = max(ybound(xtemp))+eps; %topbound
%bottombound
xtemp = find(xbound<520);
lbottombound = min(ybound(xtemp))-eps; %topbound
%bounds on left arm: lleftbound, lrightbound, ltopbound, lbottombound

%FOR RIGHT COLUMN
rrightbound = max(xbound); %rightbound
%leftbound
ytemp = find(ybound>420 | ybound<320);
xtemp = find(xbound>750);
xtemp = intersect(xtemp, ytemp);
rleftbound = min(xbound(xtemp))-eps; %rightbound
%topbound
xtemp = find(xbound>740);
rtopbound = max(ybound(xtemp))+eps; %topbound
%bottombound
xtemp = find(xbound>740);
rbottombound = min(ybound(xtemp))-eps; %topbound
%bounds on left arm: rleftbound, rrightbound, rtopbound, rbottombound

%FOR MIDDLE
%is between lrightbound and rleftbound

xtemp = find(xbound>lrightbound & xbound<rleftbound);
mtopbound = max(ybound(xtemp));
mbottombound = min(ybound(xtemp));
mleftbound = lrightbound;
mrightbound = rleftbound;
%bounds on bottom: mleftbound, mrightbound, mtopbound, mbottombound


%want to make a vector of all the increments
%LEFT ARM ALL


%left arm top
%doing 8 per  segment
bottomvec = [];
topvec = [];

interval = (ltopbound-mtopbound)./8;
for lb = 0:7
  bottomvec(end+1) = ltopbound-((lb+1)*interval);
  topvec(end+1) = ltopbound-(lb*interval);
end
leftvectemp1 = ones((length(bottomvec)),1)*lleftbound;
leftvectemp2 = ones((length(bottomvec)),1)*lrightbound;
choicetop = min(bottomvec);
lefttop = [leftvectemp1, leftvectemp2, bottomvec', topvec']; %LEFT ARM TOP

%left arm bottom
%doing 8 per  segment
bottomvec = [];
topvec = [];
interval = (mbottombound-lbottombound)./8;
for lb = 0:7
  bottomvec(end+1) = lbottombound+(lb*interval);
  topvec(end+1) = lbottombound+((lb+1)*interval);
end
leftvectemp1 = ones((length(bottomvec)),1)*lleftbound;
leftvectemp2 = ones((length(bottomvec)),1)*lrightbound;
choicebottom = max(topvec);
leftbottom = [leftvectemp1, leftvectemp2, bottomvec', topvec']; %LEFT ARM BOTTOM

%LEFT CHOICE
leftchoice = [leftvectemp1(1), leftvectemp2(2), choicebottom, choicetop]; %LEFT CHOICE


%MIDDLE ARM FROM LEFT TO RIGHT
leftvec = [];
rightvec = [];
interval = (mrightbound-mleftbound)./11;
for rb = 0:10
  leftvec(end+1) = mleftbound+(rb*interval);
  rightvec(end+1) = mleftbound+((rb+1)*interval);
end
topvectemp1 = ones((length(leftvec)),1)*mtopbound;
bottomvectemp2 = ones((length(leftvec)),1)*mbottombound;
midvect = [leftvec', rightvec', bottomvectemp2, topvectemp1]; %MIDDLE ARM
middleall = midvect;


%right ARM TOP
bottomvec = [];
topvec = [];
interval = (rtopbound-mtopbound)./8;
for lb = 0:7
  bottomvec(end+1) = rtopbound-((lb+1)*interval);
  topvec(end+1) = rtopbound-(lb*interval);
end
rightvectemp1 = ones((length(bottomvec)),1)*rleftbound;
rightvectemp2 = ones((length(bottomvec)),1)*rrightbound;
choicetop = min(bottomvec);
righttop = [rightvectemp1, rightvectemp2, bottomvec', topvec']; %RIGHT ARM TOP

%right ARM BOTTOM
bottomvec = [];
topvec = [];
interval = (mbottombound-rbottombound)./8;
for lb = 0:7
  bottomvec(end+1) = rbottombound+(lb*interval);
  topvec(end+1) = rbottombound+((lb+1)*interval);
end
rightvectemp1 = ones((length(bottomvec)),1)*rleftbound;
rightvectemp2 = ones((length(bottomvec)),1)*rrightbound;
choicebottom = max(topvec);
rightbottom = [rightvectemp1, rightvectemp2, bottomvec', topvec']; %RIGHT ARM TOP

rightchoice = [rightvectemp1(1), rightvectemp2(2), choicebottom, choicetop]; %LEFT CHOICE


lefttop;
leftbottom;
leftchoice;
middleall;
righttop;
rightbottom;
rightchoice;


%{
figure
hold on
for f = 1:8
rectangle('Position', [lefttop(f,1), lefttop(f,3), lefttop(f,2)-lefttop(f,1), lefttop(f,4)-lefttop(f,3)],  'FaceColor', 'r', 'EdgeColor', 'r');
end
for f = 1:8
rectangle('Position', [leftbottom(f,1), leftbottom(f,3), leftbottom(f,2)-leftbottom(f,1), leftbottom(f,4)-leftbottom(f,3)], 'FaceColor', 'b', 'EdgeColor', 'b');
end
for f = 1:11
rectangle('Position', [middleall(f,1), middleall(f,3), middleall(f,2)-middleall(f,1), middleall(f,4)-middleall(f,3)], 'FaceColor', 'g', 'EdgeColor', 'g');
end
for f = 1:8
rectangle('Position', [righttop(f,1), righttop(f,3), righttop(f,2)-righttop(f,1), righttop(f,4)-righttop(f,3)], 'FaceColor', 'k', 'EdgeColor', 'k');
end
for f = 1:8
rectangle('Position', [rightbottom(f,1), rightbottom(f,3), rightbottom(f,2)-rightbottom(f,1), rightbottom(f,4)-rightbottom(f,3)], 'FaceColor', 'y', 'EdgeColor', 'y');
end
f=1;
rectangle('Position', [leftchoice(f,1), leftchoice(f,3), leftchoice(f,2)-leftchoice(f,1), leftchoice(f,4)-leftchoice(f,3)], 'FaceColor', 'm', 'EdgeColor', 'm');
rectangle('Position', [rightchoice(f,1), rightchoice(f,3), rightchoice(f,2)-rightchoice(f,1), rightchoice(f,4)-rightchoice(f,3)], 'FaceColor', 'c', 'EdgeColor', 'c');
%}

lefttop;
leftbottom;
leftchoice;
middleall;
righttop;
rightbottom;
rightchoice;

scatter(x, y)

allvec = [lefttop; leftchoice; leftbottom; middleall; righttop; rightchoice; rightbottom];  %dimesions are [n, 4]
