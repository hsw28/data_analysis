function a = accelfromvel(vel, t);


	accvector = [];
	timevector = [];

	s = length(t);

	for i = 2:s-2
		vchange = vel(i+1)-vel(i-1);
		accel = vchange/(t(i+1)-t(i-1));
		accvector(end+1) = accel;
		timevector(end+1) = t(i);
	end



	a = [accvector; timevector];
