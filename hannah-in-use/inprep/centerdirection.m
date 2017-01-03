function [towardreward, awayfromreward] = centerdirection(pos)

%finds direction on the center stem if the animal is going towards or away from the reward arms


tme = pos(:,1);
tme = tme';
xpos = pos(:,2);
xpos = xpos';
ypos = pos(:,3);
ypos = ypos';

%find INDEX of points in middle
xmiddle = find(xpos>460 & xpos<864); %FOR MIDDLE ARM, WHOLE
ymiddle = find(ypos>350 & ypos<370);
%find indices that appear in both
bothindex = intersect(xmiddle, ymiddle);
%assign these to points
timemiddle = tme(bothindex);
xmiddle = xpos(bothindex);
ymiddle = ypos(bothindex);

timemiddle
posmiddle = [timemiddle; xmiddle; ymiddle];

%find directions
figure('visible','off');
dir = direction(timemiddle, pos);
% now you have [timevector; xposvector; yposvector; fxvector; fyvector];

%find times where animal is going forward and backwards
towardreward =[];
awayfromreward = [];
for i=1:size(dir,2)
	if dir(4,i) > 0;
		towardreward(end+1) = dir(1,i);
	elseif dir(4,i) < 0;
		awayfromreward(end+1) = dir(1,i);
	end
end
