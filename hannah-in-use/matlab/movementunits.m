function f = movementunits(pos, units)
% returns units only when the animal is actually running
% CHANGE MEASURE OF VELOCITY

vel = noiselessVelocity(pos);
tme = vel(2,:);
vel = vel(1,:);

if size(units,2)>size(units,1)
    units = units';
end

%finds when velocity is high (>2cm/sec)
% NEED TO CHANGE VELOCITY MEASURE
i = 1;
highvel = [];

while i<size(vel,2)
  if vel(i) > 5
      highvel(end+1) = tme(i); %start time
      while vel(i) > 5 && i<size(vel,2)
        i = i+1;
      end
      highvel(end+1) = tme(i); % end time
  else
      i = i+1;
  end
end

%take out periods that arent over 1 sec long
i = 2;
while i <=size(highvel,2)
	 if highvel(i)-highvel(i-1) < 1
		  highvel(i) = 0;
			highvel(i-1) = 0;
		end
	i = i+2;
end
highvel = highvel(highvel~=0);


% find spikes in period
i = 1;
highvelspikes = [];
while i <= size(highvel,2)
  starting = highvel(1,i); %start
  ending = highvel(1,i+1); %end
  x = find(units>starting & units<ending);
  newunits = units(x);
  newunits = newunits';
  highvelspikes=[highvelspikes, newunits];
i = i+2;
end

f = highvelspikes;
