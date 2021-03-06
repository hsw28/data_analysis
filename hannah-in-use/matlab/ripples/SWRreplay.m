function [matrices radon_results allvec] = SWRreplay(SWRstartend, pos, clusters, tdecode)

%decodes ripples in 20ms chunks using a radon transform
%input the output for findripMUA.m
%if inputting in only peak time, use varargin to specify seconds around peak time


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% DECODING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if tdecode>.1
  error('tdecode should be in fractions of seconds. for ex .02 for 20ms')
end

size(SWRstartend,1);

%if size(SWRstartend,1)==3 %means you're inputting start and end times
  SWRstart = SWRstartend(1,:);
  SWRend = SWRstartend(3,:);
%elseif size(SWRstartend,1)==1 %means you're just putting in mid time
%  timeshift = cell2mat(varargin);
%  SWRstart = SWRstartend-timeshift;
%  SWRend = SWRstartend+timeshift;
%end

%find number of clusters
clustname = (fieldnames(clusters));
numclust = length(clustname);

posData = pos;

velthreshold = 12;
vel = velocity(posData);
posData = fixpos(posData);
vel(1,:) = smoothdata(vel(1,:), 'gaussian', 30); %originally had this at 30, trying with 15 now
goodvel = find(vel>=velthreshold);

[allvec lefttop leftchoice leftbottom middleall righttop rightchoice rightbottom] = findlinearbounds(posData);

xvals = posData(:,2);
yvals = posData(:,3);



fxmatrix = firingPerPos_linear(posData, clusters, 1, 30, allvec, velthreshold);

names = (fieldnames(fxmatrix));
for k=1:length(names)
  curname = char(names(k));
  fxmatrix.(curname) = ndnanfilter(fxmatrix.(curname), 'gausswin', [2, 2], 2, {}, {'replicate'}, 1);
end

maxprob = [];
spikenum = 1;
times = [];
percents = [];
numcel = [];
maxx = [];
maxy = [];
same = 0;



occ = zeros(length(allvec),1);
testing = 0;
for xy = (1:size(allvec,1)) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES

    occx = find(xvals>=allvec(xy,1) & xvals<allvec(xy,2));
    occy = find(yvals>=allvec(xy,3) & yvals<allvec(xy,4));
    if length(intersect(occx, occy)) ==0
      occ(xy) = 0;
    else
      occ(xy) = 1;
    end

end

n =0;
nivector = zeros((numclust),1);

all_decoded = NaN(5,10, length(SWRstart));
for r=1:(length(SWRstart))
endproball = [];

  currend = SWRstart(r);
  newend = currend;
  maxx = [];
  maxy= [];
  percents= [];
  currstart_vec = [];
  currend_vec = [];

  while newend < SWRend(r)
    currstart = currend;
      currend = newend;


  %dont need to make sure the animal is moving bc ripple
   %find spikes in each cluster for time

   nivector = zeros((numclust),1);
   for c=1:numclust   %permute through cluster
     name = char(clustname(c));
     nivector(c) = length(find(clusters.(name)>=currstart & clusters.(name)<currend));
   end

   %for the cluster, permute through the different conditions
 endprob = zeros(length(allvec),1);

 for xy = (1:size(allvec,1)) %WANT TO PERMUTE THROUGH EACH SQUARE OF SPACE SKIPPING NON OCCUPIED SQUARES. SO EACH BIN SHOULD HAVE TWO COORDINATES
     productme =0;
     expme = 0;
     c = 1;

     if occ(xy) == 0 %means never went there, dont consider
       endprob(xy) = NaN;
     %  break
     end

     for c=1:numclust  %permute through cluster
         ni = nivector(c);
         name = char(clustname(c));
         fx = fxmatrix.(name);

         fx = (fx(xy));
         productme = productme + (ni)*log(fx);  %IN
         expme = (expme) + (fx);
          % goes to next cell, same location

     end

     numcel(end+1) = (ni);
     % now have all cells at that location
     tmm = currend-currstart;

    endprob(xy) = (productme) + (-tmm.*expme); %IN

end

[maxval] = find(endprob == max(endprob(:)));

mp = max(endprob(:))-12;

endprob = exp(endprob-mp);


%finds indices
conv = 1./sum(endprob(~isnan(endprob)), 'all');
endprob = endprob.*conv; %matrix of percents
endproball = [endproball, endprob];
%percents = vertcat(percents, endprob);

percents(end+1) = max(endprob(:)); %finds confidence
if length(maxval) > 1 %if probs are the sample, randomly pick one and print warning
   same = same+1;
   maxval = datasample(maxval, 1);
   maxval = datasample(maxval, 1);

end

currstart_vec(end+1) = currstart;
currend_vec(end+1) = currend;

   if length(maxval) <1
     maxx(end+1) = NaN;
     maxy(end+1) = NaN;
   else
     maxx(end+1) = mean([allvec(maxval,1), allvec(maxval,2)]); %translates to x and y coordinates
     maxy(end+1) = mean([allvec(maxval,3), allvec(maxval,4)]);
   end


   newend = currend+tdecode;


end

num = num2str(r);
name = strcat('rip', num);
name = char(name);
matrices.(name) = endproball;


values = [maxx; maxy; percents; currstart_vec; currend_vec];
all_decoded(:,1:length(values),r)= values;

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% LINEARIZING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%[allvec lefttop leftchoice leftbottom middleall righttop rightchoice rightbottom]
%LENGTHS
%lefttop is 8
%leftchoice is 1
%leftbottom is 8
%middleall is 11
%righttop is 8
%rightchoice is 1
%rightbottom is 8


lefttop_indx = [1:8];
leftchoice_indx = [9];
leftbottom_indx = [10:17];
middleall_indx = [18:28];
righttop_indx = [29:36];
rightchoice_indx = [37];
rightbottom_indx =[38:45];

%traj:
traj1 = [lefttop_indx, leftchoice_indx, leftbottom_indx];                                       %1 = only left arm
traj2 = [righttop_indx, rightchoice_indx,  rightbottom_indx];                                   %2 = only right arm
traj3 = [lefttop_indx, leftchoice_indx, middleall_indx, rightchoice_indx, righttop_indx];       %3 = left TOP, middle, right TOP
traj4 = [leftbottom_indx, leftchoice_indx, middleall_indx, rightchoice_indx, rightbottom_indx]; %4 = left BOTTOM, middle, right BOTTOM
traj5 = [lefttop_indx, leftchoice_indx, middleall_indx, rightchoice_indx, rightbottom_indx];    %5 = left TOP, middle, right BOTTOM
traj6 = [leftbottom_indx, leftchoice_indx, middleall_indx, rightchoice_indx, righttop_indx];    %6 = left BOTTOM, middle, right TOP

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% RADON %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ripnames = fieldnames(matrices);
ripnum = length(ripnames);

slope_all = NaN(ripnum,1);
intercept_all = NaN(ripnum,1);
score_all = NaN(ripnum,1);
traj_all = NaN(ripnum,1);
a1_all = NaN(ripnum,1);
a2_all = NaN(ripnum,1);
a3_all = NaN(ripnum,1);
a4_all = NaN(ripnum,1);
a5_all = NaN(ripnum,1);
%projection_all = NaN(ripnum,1);
%permute through ripples

for k = 1:ripnum
  name = char(ripnames(k));
  matrices_currentrip = matrices.(name);
  score_old = 0;
  slope = [];
  score = [];
  intercept = [];
  projection = [];

  %TODO: MAKE POS SIZES ACTUAL



timestep = 1/tdecode;



  [slope_new, intercept_new, score_new, projection_new]  = est_line_detect([(1:1:size(matrices_currentrip,2))], [1:size(matrices_currentrip([traj1],:))], matrices_currentrip([traj1],:));
  if score_new > score_old
    score_old = score_new;
    score = score_new;
    slope = slope_new;
    intercept = intercept_new;
    projection = projection_new;
    traj = 1;

    p = size(matrices_currentrip([traj1],:),2);
    y = (slope)*(1:p)+intercept;
    y = round(y);
    a1 = length(find(y<=8 | y>9));
    a2 = length(find(y==9));
    a3 = NaN;
    a4 = NaN;
    a5 = NaN;

  end
  [slope_new, intercept_new, score_new, projection_new]  = est_line_detect([(1:1:size(matrices_currentrip,2))], [1:size(matrices_currentrip([traj2],:))], matrices_currentrip([traj2],:));
  if score_new > score_old
    score_old = score_new;
    score = score_new;
    slope = slope_new;
    intercept = intercept_new;
    projection = projection_new;
    traj = 2;

    p = size(matrices_currentrip([traj2],:),2);
    y = (slope)*(1:p)+intercept;
    y = round(y);
    a1 = NaN;
    a2 = NaN;
    a3 = NaN;
    a4 = length(find(y==9));
    a5 = length(find(y<=8 | y>9));
  end

  [slope_new, intercept_new, score_new, projection_new]  = est_line_detect([(1:1:size(matrices_currentrip,2))], [1:size(matrices_currentrip([traj3],:))], matrices_currentrip([traj3],:));
  if score_new > score_old
    score_old = score_new;
    score = score_new;
    slope = slope_new;
    intercept = intercept_new;
    projection = projection_new;
    traj = 3;

    p = size(matrices_currentrip([traj3],:),2);
    y = (slope)*(1:p)+intercept;
    y = round(y);
    a1 = length(find(y<=8));
    a2 = length(find(y==9));
    a3 = length(find(y>9 & y<=20));
    a4 = length(find(y==21));
    a5 = length(find(y>21));
  end

  [slope_new, intercept_new, score_new, projection_new]  = est_line_detect([(1:1:size(matrices_currentrip,2))], [1:size(matrices_currentrip([traj4],:))], matrices_currentrip([traj4],:));
  if score_new > score_old
    score_old = score_new;
    score = score_new;
    slope = slope_new;
    intercept = intercept_new;
    projection = projection_new;
    traj = 4;

    p = size(matrices_currentrip([traj4],:),2);
    y = (slope)*(1:p)+intercept;
    y = round(y);
    a1 = length(find(y<=8));
    a2 = length(find(y==9));
    a3 = length(find(y>9 & y<=20));
    a4 = length(find(y==21));
    a5 = length(find(y>21));
  end

  [slope_new, intercept_new, score_new, projection_new]  = est_line_detect([(1:1:size(matrices_currentrip,2))], [1:size(matrices_currentrip([traj5],:))], matrices_currentrip([traj5],:));
  if score_new > score_old
    score_old = score_new;
    score = score_new;
    slope = slope_new;
    intercept = intercept_new;
    projection = projection_new;
    traj = 5;

    p = size(matrices_currentrip([traj5],:),2);
    y = (slope)*(1:p)+intercept;
    y = round(y);
    a1 = length(find(y<=8));
    a2 = length(find(y==9));
    a3 = length(find(y>9 & y<=20));
    a4 = length(find(y==21));
    a5 = length(find(y>21));
  end

  [slope_new, intercept_new, score_new, projection_new]  = est_line_detect([(1:1:size(matrices_currentrip,2))], [1:size(matrices_currentrip([traj6],:))], matrices_currentrip([traj6],:));
  if score_new > score_old
    score_old = score_new;
    score = score_new;
    slope = slope_new;
    intercept = intercept_new;
    projection = projection_new;
    traj = 6;

    p = size(matrices_currentrip([traj6],:),2);
    y = (slope)*(1:p)+intercept;
    y = round(y);
    a1 = length(find(y<=8));
    a2 = length(find(y==9));
    a3 = length(find(y>9 & y<=20));
    a4 = length(find(y==21));
    a5 = length(find(y>21));
  end

  slope_all(k) = slope;
  intercept_all(k) = intercept;
  score_all(k) =score;
  traj_all(k) = traj;
  a1_all(k) = a1;
  a2_all(k) = a2;
  a3_all(k) = a3;
  a4_all(k) = a4;
  a5_all(k) = a5;

end

%{
traj1 = [lefttop_indx, leftchoice_indx, leftbottom_indx];                                       %1 = only left arm
8 1 8
traj2 = [righttop_indx, rightchoice_indx,  rightbottom_indx];                                   %2 = only right arm
8 1 8
traj3 = [lefttop_indx, leftchoice_indx, middleall_indx, rightchoice_indx, righttop_indx];       %3 = left TOP, middle, right TOP
8 1 11 1 8
traj4 = [leftbottom_indx, leftchoice_indx, middleall_indx, rightchoice_indx, rightbottom_indx]; %4 = left BOTTOM, middle, right BOTTOM
8 1 11 1 8
traj5 = [lefttop_indx, leftchoice_indx, middleall_indx, rightchoice_indx, rightbottom_indx];    %5 = left TOP, middle, right BOTTOM
8 1 11 1 8
traj6 = [leftbottom_indx, leftchoice_indx, middleall_indx, rightchoice_indx, righttop_indx];    %6 = left BOTTOM, middle, right TOP
8 1 11 1 8
%}

radon_results = [traj_all, score_all, slope_all, intercept_all, a1_all,  a2_all,  a3_all,  a4_all,  a5_all];

%TODO: randomized/shuffled
%convert output into meaningful numbers of where the rat is
%I think positive slope should mean towards reward and negative should mean away, except in traj 1 and 2
