function f = quadranterror(decoded, pos)
%tells you the amount of error in cm per animals position in each quadrant, per each velocity

  time = decoded(4,:);
  X = decoded(1,:);
  Y = decoded(2,:);


  forceindexleft = [];
  forceindexright = [];
  choiceindexleft = [];
  choiceindexright = [];

  middleindex = [];

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

figure
decodeddiff(decoded(:, forceindexleft), pos)
%sgtitle('forced left')

figure
decodeddiff(decoded(:, forceindexright), pos)
%sgtitle('forced right')


figure
decodeddiff(decoded(:, choiceindexleft), pos)
%sgtitle('choice left')


figure
decodeddiff(decoded(:, choiceindexright), pos)
%sgtitle('choice right')

figure
decodeddiff(decoded(:, middleindex), pos)
%sgtitle('middle stem')
