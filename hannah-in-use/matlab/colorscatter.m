function f = colorscatter(xinput, yinput, colorinput)



valuecolorinput=(colorinput(~isnan(colorinput)));
uniquevalues = (unique(valuecolorinput));
colors = hsv(length(uniquevalues))
colors(2,2) = 0;
%plot all that aren't NaN for color input

gscatter(xinput(~isnan(colorinput)),yinput(~isnan(colorinput)),colorinput(~isnan(colorinput)), colors)

%colors = distinguishable_colors(length(uniquevalues));

%f = figure
%hold on



%for k=1:length(uniquevalues)
%    index = find(colorinput == uniquevalues(k));
%    scatter(xinput(index), yinput(index), 25, colors(k), 'filled')
%end
