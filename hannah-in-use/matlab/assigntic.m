function a = assigntic(event, pos)

% assigns video tic numbers to an even
% input position file imported from csv in format (data, 3)
% 
% event should be a list of time stamps like (1, timestamps)
%
% outputs a matrix with time, xpos, ypos
%
% ex: 
% txy = assigntic(ripples, positionfile);

eventsize = size(event,2);
alltimes = pos(:,1);

at = size(alltimes);

tic = [];

i = 1;
newn = 1;
while i <= eventsize
	m = [];
	for n = 1:size(alltimes)
		m(end+1) = (abs(event(i)-(alltimes(n))));
		if size(m,2) == 1
			ticnum(i) = n;
			
		end

		if size(m,2)>1
			if m(end)<=m(end-1)
				ticnum(i) = n;
			end

			if m(end)>m(end-1)
				break
			end
		end	
	end

i=i+1;

end

a=[event;ticnum];
