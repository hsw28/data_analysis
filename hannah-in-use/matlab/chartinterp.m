function f = chartinterp(chart)

  %interpolates points within the boundary of a maze. takes data from, for example, normalize pos Data
  %outputs map


  [x, y] = find(isnan(chart) == 0); %finds number values of original shape
  shp = alphaShape(x,y); %finds boundaries of original shape

  [x, y] = find(isnan(chart) == 1); %finds nan values of original shape
  f = [x,y];
  tf = inShape(shp,x,y); %finds NaN values in shape

  notinshape = find(tf == 0); %indices of NaN values not in shape

  actualX = x(notinshape);
  actualY = y(notinshape);

  interpchart = inpaint_nans(chart, 2); %interps NaN values
  interpchartlinear = sub2ind(size(interpchart),actualX,actualY);
  interpchart(interpchartlinear) = NaN;
  f = interpchart;
