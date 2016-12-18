function f = firingphase(firingtimes, lfp, timevector, above)

%input lfp, cell firing, time vector, and how many std devs above mean you want a peak to be to be counted in theta

%finds theta peak closest peak to cell firing for LS LFP
% plots histogram
%
% returns [phase, time]

tme = timevector;
peaktimes = thetaphase(lfp, tme, above);

phase = [];

%peaktimes(312:313)
ftimes = [];


i = 1;
size(firingtimes);
while i<= size(firingtimes,1)
	x = find( abs(peaktimes-firingtimes(i)) < .17);
	%makes sure we only have one point. point is the time of the closest peak
		if size(x,1) == 0
			i = i+1;
		else

			if size(x,1) == 1
				point = peaktimes(x);
			elseif size(x,1) > 1
				r = 1;
				z = 100;
				closer = [];
				while r<=size(x,1)				
					if  abs(firingtimes(i) - peaktimes(x(r))) < z
						z = abs(firingtimes(i) - peaktimes(x(r)));
						closer = x(r);
						r = r+1;
					else
						r= r+1;
					end
				end
				x = closer;
				point = peaktimes(closer);
			end
			%have one point, have to see if it's before or after the firing time
			% if point is before or on firing time, firing time - point will be 0 or positive
			if firingtimes(i)-point >= 0 %point is before
				%find next point
				
				if x+1 >= size(peaktimes,1)
					break
				end
				
				nextpoint = peaktimes(x+1);
				peaklength = abs(point-nextpoint);
				%now need to make sure the distance between the two points are 6-12hz and that the next point is further than the firing point
				 
				
				if peaklength >= .08 & peaklength <= .17 & nextpoint>firingtimes(i)
					
					dis = firingtimes(i)-point;
					phase(end+1) = dis*360 / peaklength;
					ftimes(end+1) = firingtimes(i);
					%dis/peaklength
				end
					

			elseif firingtimes(i)-point < 0 % point is after
				% find previous point
				previouspoint = peaktimes(x-1);
				peaklength = abs(point-previouspoint);
				%now need to make sure the distance between the two points are 6-12hz. if not, move on
				if peaklength >= .08 & peaklength <= .17 & previouspoint<firingtimes(i)
					dis = firingtimes(i)-previouspoint;
					phase(end+1) = dis*360 / peaklength;
					ftimes(end+1) = firingtimes(i);
					
				end
			else
				firingtimes(i)-point
			end
			

		

		i = i+1;
		end
end

f = [phase; ftimes];
figure;

histogram(phase, 24)
xlim([0 360]);
ylabel('Number of Cells')
xlabel('Theta Phase')
