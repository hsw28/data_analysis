function f = findquad(x,y)

  xlimmin = [300 300 320 320 320 450 750 780 828 780 780];
  xlimmax = [505 450 450 505 505 850 950 950 950 950 950];
  ylimmin = [545 422 320 170 000 300 575 420 339 182 000];
  ylimmax = [700 545 422 320 170 440 700 575 420 339 182];
  %position 1: end of left forced
  %position 2: left forced
  %position 3: forced choice point
  %position 4: right forced
  %position 5: end of right forced
  %position 6: middle stem
  %position 7: end of left choice
  %position 8 left choice arm
  %position 9: free choice point
  %position 10: right choice arm
  %position 11: end of right choice arm

  %1 = 1, 2 and 4,5 grouped as forced arms
  %2 = 3 is forced point
  %3 = 6 is middle stem
  %4 = 7,8 and 10,11 grouped as choice arms
  %5 = 9 is free choice point

posQuadmax = zeros(length(x), 1);
for k=1:length(xlimmin)
  inX = find(x > xlimmin(k) & x <=xlimmax(k));
  inY = find(y > ylimmin(k) & y <=ylimmax(k));
  inboth = intersect(inX, inY);
  if (k == 2 | k== 4)        %|k== 1 | k== 5 %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 1;
  elseif k == 3                                 %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 2;
  elseif (k== 1 | k== 5)
    posQuadmax(inboth) = 0;
  elseif k == 6                        %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 3;
  elseif (k == 8 | k== 10 )                %| k== 7 | k== 11          %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 5;
  elseif (k== 7 | k== 11)
    posQuadmax(inboth) = 6;
  elseif k == 9                                    %& vel(inboth(z))>threshold
    posQuadmax(inboth) = 4;
  else
    posQuadmax(inboth) = NaN;
  end
end

f = posQuadmax;
