function f = firingphase(firingtimes, lfp, timevector, above, bins)
% DONT PUT IN A FILTERED LFP, THE CODE DOES THAT FOR YOU
%input lfp, cell firing, time vector, and how many std devs above mean you want a peak to be to be counted in theta
%bins is in number of degrees per bin (ex 60 for sixty degrees per bin)

%finds theta peak closest peak to cell firing for LS LFP
% plots histogram
%
% returns [phase, time]

if size(firingtimes,2)>size(firingtimes,1)
    firingtimes = firingtimes';
end


tme = timevector;
%determines peaks of theta
peaktimes = thetaphase(lfp, tme, above);
troughtimes = thetaphase(lfp.*-1, tme, above);

phase = [];
ftimes = [];
test = 0;


i = 1;
size(firingtimes);
while i<= size(firingtimes,1)
	x = find( abs(peaktimes-firingtimes(i)) < .17);

	%makes sure we only have one point. point is the time of the closest peak
		if size(x,1) == 0 %this means no peaks satisfy
			i = i+1;
		else %if some peaks satisfy
			if size(x,1) == 1 %if one peak only satisfies, you're golden
				point = peaktimes(x);
			elseif size(x,1) > 1 % if more than one peak satisfies, take the closer point
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
			% have one point, have to see if it's before or after the firing time
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

          tt = find(troughtimes < nextpoint & troughtimes > point); %finds minima
          tt = troughtimes(tt);
          % if troughtime minus point is negative, trough comes first. if positive, point comes first
          if tt-firingtimes(i) < 0 & size(tt,1) == 1; % trough is first
              dis = firingtimes(i)-tt;
              phase(end+1) = (dis*180 / abs(tt-nextpoint) + 180);
              ftimes(end+1) = firingtimes(i);
          elseif tt-firingtimes(i) > 0 & size(tt,1) == 1; % point is first
              dis = firingtimes(i)-point;
              phase(end+1) = (dis*180 / abs(tt-point));
              ftimes(end+1) = firingtimes(i);
          elseif tt-firingtimes(i) == 0 & size(tt,1) == 1; % point is on trough
            phase(end+1) = 180;
            ftimes(end+1) = firingtimes(i);
          else
            dis = firingtimes(i)-point;
					  phase(end+1) = dis*360 / peaklength;
					  ftimes(end+1) = firingtimes(i);
          end

				end


			elseif firingtimes(i)-point < 0 % point is after
				% find previous point
        if x > 1
				      previouspoint = peaktimes(x-1);
				      peaklength = abs(point-previouspoint);
				%now need to make sure the distance between the two points are 6-12hz. if not, move on

				    if peaklength >= .08 & peaklength <= .17 & previouspoint<firingtimes(i)
              tt = find(troughtimes < point & troughtimes > previouspoint); %finds minima
              tt = troughtimes(tt);

              if tt-firingtimes(i) < 0 & size(tt,1) == 1; % trough is first
                dis = firingtimes(i)-tt;
                phase(end+1) = (dis*180 / abs(tt-point) + 180);
                ftimes(end+1) = firingtimes(i);
              elseif tt-firingtimes(i) > 0 & size(tt,1) == 1; % point is first
                dis = firingtimes(i)-previouspoint;
                phase(end+1) = (dis*180 / abs(tt-previouspoint));
                ftimes(end+1) = firingtimes(i);
              elseif tt-firingtimes(i) == 0 & size(tt,1) == 1; % point is on trough
                phase(end+1) = 180;
                ftimes(end+1) = firingtimes(i);
              else
                dis = firingtimes(i)-previouspoint;
				  	    phase(end+1) = dis*360 / peaklength;
				  	    ftimes(end+1) = firingtimes(i);
              end
          end
      end




				end






		i = i+1;
		end
end


f = [phase; ftimes];
figure;

bincount = 360/bins;
histogram(phase, bincount, 'BinWidth', bins)
xlim([0 360]);

ylabel('Number of Cells')
xlabel('Theta Phase')
