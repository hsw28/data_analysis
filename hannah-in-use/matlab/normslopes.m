function ratio = normslopes(slopes1, slopes2);

ratio = abs((abs(slopes1)-abs(slopes2))./(abs(slopes1)+abs(slopes2)));
