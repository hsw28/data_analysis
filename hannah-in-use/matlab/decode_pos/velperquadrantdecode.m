function f = velperquadrantdecode(decoded, pos)
%for each section (each forced arm, each choice arm, and center stem) of the maze, tells you which section is decoded and the velocity during decoding

time = decoded(4,:);
X = decoded(1,:);
Y = decoded(2,:);


forceindexleft = [];
forceindexright = [];

choiceindexleft = [];
choiceindexright = [];

middleindex = [];

vel = velocity(pos);

for i=1:length(X)
    [c index] = (min(abs(time(i)-pos(:,1))));
    % pos(index,2), pos(index,3) <-- position coordinates
    if pos(index,2) < 480 & pos(index,3) > 397 %forced arm left
        forceindexleft(end+1) = i;
    elseif pos(index,2) < 480 & pos(index,3) < 343 %forced arm right
        forceindexright(end+1) = i;
    elseif pos(index,2) > 810 & pos(index,3) > 410%choice left arm
        choiceindexleft(end+1) = i;
    elseif pos(index,2) > 810 & pos(index,3) < 368 %choice right arm
        choiceindexright(end+1) = i;
    else %middle
        middleindex(end+1) = i;
    end
end

%breaking down actual forced left
fl = 0;
fr = 0;
cl = 0;
cr = 0;
m = 0;
flvel = [];
frvel = [];
clvel = [];
crvel = [];
mvel = [];
length(forceindexleft)
for i = 1:length(forceindexleft)
  if decoded(1,forceindexleft(i)) < 442 & decoded(2,forceindexleft(i)) > 370 %then decoding is in forced left
    fl = fl+1;
    flvel(end+1) = vel(1,i);
  elseif decoded(1,forceindexleft(i)) < 442 & decoded(2,forceindexleft(i)) < 300 %then decoding is in forced right
    fr = fr+1;
    frvel(end+1) = vel(1,i);
  elseif decoded(1,forceindexleft(i)) > 790 & decoded(2,forceindexleft(i)) > 405 %then decoding is in choise left
    cl = cl+1;
    clvel(end+1) = vel(1,i);
  elseif decoded(1,forceindexleft(i)) > 790 & decoded(2,forceindexleft(i)) < 335 %then decoding is in choise right
    cr = cr+1;
    crvel(end+1) = vel(1,i);
  else
    m = m+1;
    mvel(end+1) = vel(1,i);
  end
end
figure

x = ones(1, length(flvel));
plot(x, flvel, 'b*', 'MarkerSize', 5, 'LineWidth', 3);
hold on;
x = 1.1 * ones(1, length(frvel));
plot(x, frvel, 'r*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.2 * ones(1, length(clvel));
plot(x, clvel, 'c*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.3 * ones(1, length(crvel));
plot(x, crvel, 'g*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.4 * ones(1, length(mvel));
plot(x, mvel, 'k*', 'MarkerSize', 5, 'LineWidth', 3);
ax = gca;
ax.XTick = [1, 1.1, 1.2, 1.3, 1.4];
ax.XTickLabels = {'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'};
ylabel 'Velocity (cm/s)'
xlabel 'Decoded Position'
title 'Animal is on left forced arm'

figure
plot([1, 1.1, 1.2, 1.3, 1.4], [mean(flvel), mean(frvel), mean(clvel), mean(crvel), mean(mvel)], 'k*', 'MarkerSize', 10, 'LineWidth', 3);
ax = gca;
ax.XTick = [1, 1.1, 1.2, 1.3, 1.4];
ax.XTickLabels = {'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'};
ylabel 'Average Velocity (cm/s)'
xlabel 'Decoded Position'
title 'Animal is on left forced arm'

figure
all = fl+fr+cl+cr+m;
dec = [fl fr cl cr m]./all;
bar(dec)
ylim ([0 .6])
set(gca,'xticklabel',{'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'});
ylabel 'Percent'
xlabel 'Decoded'
title 'Animal is on left forced arm'


fl = 0;
fr = 0;
cl = 0;
cr = 0;
m = 0;
flvel = [];
frvel = [];
clvel = [];
crvel = [];
mvel = [];
for i = 1:length(forceindexright)
  if decoded(1,forceindexright(i)) < 442 & decoded(2,forceindexright(i)) > 370 %then decoding is in forced left
    fl = fl+1;
    flvel(end+1) = vel(1,i);
  elseif decoded(1,forceindexright(i)) < 442 & decoded(2,forceindexright(i)) < 300 %then decoding is in forced right
    fr = fr+1;
    frvel(end+1) = vel(1,i);
  elseif decoded(1,forceindexright(i)) > 790 & decoded(2,forceindexright(i)) > 405 %then decoding is in choise left
    cl = cl+1;
    clvel(end+1) = vel(1,i);
  elseif decoded(1,forceindexright(i)) > 790 & decoded(2,forceindexright(i)) < 335 %then decoding is in choise right
    cr = cr+1;
    crvel(end+1) = vel(1,i);
  else
    m = m+1;
    mvel(end+1) = vel(1,i);
  end
end
figure
all = fl+fr+cl+cr+m;
dec = [fl fr cl cr m]./all;
bar(dec)
ylim ([0 .6])
set(gca,'xticklabel',{'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'});
ylabel 'Percent'
xlabel 'Decoded'
title 'Animal is on right forced arm'
figure
x = ones(1, length(flvel));
plot(x, flvel, 'b*', 'MarkerSize', 5, 'LineWidth', 3);
hold on;
x = 1.1 * ones(1, length(frvel));
plot(x, frvel, 'r*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.2 * ones(1, length(clvel));
plot(x, clvel, 'c*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.3 * ones(1, length(crvel));
plot(x, crvel, 'g*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.4 * ones(1, length(mvel));
plot(x, mvel, 'k*', 'MarkerSize', 5, 'LineWidth', 3);
ax = gca;
ax.XTick = [1, 1.1, 1.2, 1.3, 1.4];
ax.XTickLabels = {'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'};
ylabel 'Velocity (cm/s)'
xlabel 'Decoded Position'
title 'Animal is on right forced arm'
figure
plot([1, 1.1, 1.2, 1.3, 1.4], [mean(flvel), mean(frvel), mean(clvel), mean(crvel), mean(mvel)], 'k*', 'MarkerSize', 10, 'LineWidth', 3);
ax = gca;
ax.XTick = [1, 1.1, 1.2, 1.3, 1.4];
ax.XTickLabels = {'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'};
ylabel 'Average Velocity (cm/s)'
xlabel 'Decoded Position'
title 'Animal is on right forced arm'

fl = 0;
fr = 0;
cl = 0;
cr = 0;
m = 0;
flvel = [];
frvel = [];
clvel = [];
crvel = [];
mvel = [];
for i = 1:length(choiceindexleft)
  if decoded(1,choiceindexleft(i)) < 442 & decoded(2,choiceindexleft(i)) > 370 %then decoding is in forced left
    fl = fl+1;
flvel(end+1) = vel(1,i);
  elseif decoded(1,choiceindexleft(i)) < 442 & decoded(2,choiceindexleft(i)) < 300 %then decoding is in forced right
    fr = fr+1;
frvel(end+1) = vel(1,i);
  elseif decoded(1,choiceindexleft(i)) > 790 & decoded(2,choiceindexleft(i)) > 405 %then decoding is in choise left
    cl = cl+1;
clvel(end+1) = vel(1,i);
  elseif decoded(1,choiceindexleft(i)) > 790 & decoded(2,choiceindexleft(i)) < 335 %then decoding is in choise right
    cr = cr+1;
    crvel(end+1) = vel(1,i);
  else
    m = m+1;
    mvel(end+1) = vel(1,i);
  end
end
figure
all = fl+fr+cl+cr+m;
dec = [fl fr cl cr m]./all;
bar(dec)
ylim ([0 .6])
set(gca,'xticklabel',{'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'});
ylabel 'Percent'
title 'Animal is on left choice arm'
xlabel 'Decoded'
figure
x = ones(1, length(flvel));
plot(x, flvel, 'b*', 'MarkerSize', 5, 'LineWidth', 3);
hold on;
x = 1.1 * ones(1, length(frvel));
plot(x, frvel, 'r*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.2 * ones(1, length(clvel));
plot(x, clvel, 'c*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.3 * ones(1, length(crvel));
plot(x, crvel, 'g*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.4 * ones(1, length(mvel));
plot(x, mvel, 'k*', 'MarkerSize', 5, 'LineWidth', 3);
ax = gca;
ax.XTick = [1, 1.1, 1.2, 1.3, 1.4];
ax.XTickLabels = {'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'};
ylabel 'Velocity (cm/s)'
xlabel 'Decoded Position'
title 'Animal is on left choice arm'
figure
plot([1, 1.1, 1.2, 1.3, 1.4], [mean(flvel), mean(frvel), mean(clvel), mean(crvel), mean(mvel)], 'k*', 'MarkerSize', 10, 'LineWidth', 3);
ax = gca;
ax.XTick = [1, 1.1, 1.2, 1.3, 1.4];
ax.XTickLabels = {'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'};
ylabel 'Average Velocity (cm/s)'
xlabel 'Decoded Position'
title 'Animal is on left choice arm'


fl = 0;
fr = 0;
cl = 0;
cr = 0;
m = 0;
flvel = [];
frvel = [];
clvel = [];
crvel = [];
mvel = [];
for i = 1:length(choiceindexright)
  if decoded(1,choiceindexright(i)) < 442 & decoded(2,choiceindexright(i)) > 370 %then decoding is in forced left
    fl = fl+1;
flvel(end+1) = vel(1,i);
  elseif decoded(1,choiceindexright(i)) < 442 & decoded(2,choiceindexright(i)) < 300 %then decoding is in forced right
    fr = fr+1;
frvel(end+1) = vel(1,i);
  elseif decoded(1,choiceindexright(i)) > 790 & decoded(2,choiceindexright(i)) > 405 %then decoding is in choise left
    cl = cl+1;
clvel(end+1) = vel(1,i);
  elseif decoded(1,choiceindexright(i)) > 790 & decoded(2,choiceindexright(i)) < 335 %then decoding is in choise right
    cr = cr+1;
    crvel(end+1) = vel(1,i);
  else
    m = m+1;
    mvel(end+1) = vel(1,i);
  end
end
figure
all = fl+fr+cl+cr+m;
dec = [fl fr cl cr m]./all;
bar(dec)
ylim ([0 .6])
set(gca,'xticklabel',{'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'});
ylabel 'Percent'
xlabel 'Decoded'
title 'Animal is on right choice arm'
figure
x = ones(1, length(flvel));
plot(x, flvel, 'b*', 'MarkerSize', 5, 'LineWidth', 3);
hold on;
x = 1.1 * ones(1, length(frvel));
plot(x, frvel, 'r*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.2 * ones(1, length(clvel));
plot(x, clvel, 'c*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.3 * ones(1, length(crvel));
plot(x, crvel, 'g*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.4 * ones(1, length(mvel));
plot(x, mvel, 'k*', 'MarkerSize', 5, 'LineWidth', 3);
ax = gca;
ax.XTick = [1, 1.1, 1.2, 1.3, 1.4];
ax.XTickLabels = {'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'};
ylabel 'Velocity (cm/s)'
xlabel 'Decoded Position'
title 'Animal is on right choice arm'
figure
plot([1, 1.1, 1.2, 1.3, 1.4], [mean(flvel), mean(frvel), mean(clvel), mean(crvel), mean(mvel)], 'k*', 'MarkerSize', 10, 'LineWidth', 3);
ax = gca;
ax.XTick = [1, 1.1, 1.2, 1.3, 1.4];
ax.XTickLabels = {'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'};
ylabel 'Average Velocity (cm/s)'
xlabel 'Decoded Position'
title 'Animal is on right choice arm'


fl = 0;
fr = 0;
cl = 0;
cr = 0;
m = 0;
flvel = [];
frvel = [];
clvel = [];
crvel = [];
mvel = [];
for i = 1:length(middleindex)
  if decoded(1,middleindex(i)) < 442 & decoded(2,middleindex(i)) > 370 %then decoding is in forced left
    fl = fl+1;
flvel(end+1) = vel(1,i);
  elseif decoded(1,middleindex(i)) < 442 & decoded(2,middleindex(i)) < 300 %then decoding is in forced right
    fr = fr+1;
frvel(end+1) = vel(1,i);
  elseif decoded(1,middleindex(i)) > 790 & decoded(2,middleindex(i)) > 405 %then decoding is in choise left
    cl = cl+1;
clvel(end+1) = vel(1,i);
  elseif decoded(1,middleindex(i)) > 790 & decoded(2,middleindex(i)) < 335 %then decoding is in choise right
    cr = cr+1;
    crvel(end+1) = vel(1,i);
  else
    m = m+1;
    mvel(end+1) = vel(1,i);
  end
end
figure
all = fl+fr+cl+cr+m;
dec = [fl fr cl cr m]./all;
bar(dec)
ylim ([0 .6])
set(gca,'xticklabel',{'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'});
ylabel 'Percent'
xlabel 'Decoded'
title 'Animal is on center stem '
figure
x = ones(1, length(flvel));
plot(x, flvel, 'b*', 'MarkerSize', 5, 'LineWidth', 3);
hold on;
x = 1.1 * ones(1, length(frvel));
plot(x, frvel, 'r*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.2 * ones(1, length(clvel));
plot(x, clvel, 'c*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.3 * ones(1, length(crvel));
plot(x, crvel, 'g*', 'MarkerSize', 5, 'LineWidth', 3);
x = 1.4 * ones(1, length(mvel));
plot(x, mvel, 'k*', 'MarkerSize', 5, 'LineWidth', 3);
ax = gca;
ax.XTick = [1, 1.1, 1.2, 1.3, 1.4];
ax.XTickLabels = {'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'};
ylabel 'Velocity (cm/s)'
xlabel 'Decoded Position'
title 'Animal is on center stem'
figure
plot([1, 1.1, 1.2, 1.3, 1.4], [mean(flvel), mean(frvel), mean(clvel), mean(crvel), mean(mvel)], 'k*', 'MarkerSize', 10, 'LineWidth', 3);
ax = gca;
ax.XTick = [1, 1.1, 1.2, 1.3, 1.4];
ax.XTickLabels = {'ForcedLeft','ForcedRight','ChoiceLeft', 'ChoiceRight', 'Center'};
ylabel 'Average Velocity (cm/s)'
xlabel 'Decoded Position'
title 'Animal is on center stem '



%-----------
%figure
%histogram(decoded(1,forceindexleft), 'BinWidth', 150, 'Normalization', 'probability')
%xlabel 'Decoded X coordinate'
%ylabel 'Percent decoded'
%title 'left forced arm'
%figure
%histogram(decoded(1,forceindexright), 'BinWidth', 150, 'Normalization', 'probability')
%xlabel 'Decoded X coordinate'
%ylabel 'Percent decoded'
%title 'right forced arm'
%figure
%histogram(decoded(1,choiceindexleft), 'BinWidth', 150, 'Normalization', 'probability')
%xlabel 'Decoded X coordinate'
%ylabel 'Percent decoded'
%title 'right choice arm'
%figure
%histogram(decoded(1,choiceindexright), 'BinWidth', 150, 'Normalization', 'probability')
%xlabel 'Decoded X coordinate'
%ylabel 'Percent decoded'
%title 'left choice arm'
%figure
%histogram(decoded(1,middleindex), 'BinWidth', 150, 'Normalization', 'probability')
%xlabel 'Decoded X coordinate'
%ylabel 'Percent decoded'
%title 'middle stem'
