function f = STAfake(eventtimes, lfp, time, vel, binsize);

% plots the STA and fake points on same graphs. ONLY uses times when the animal is moving

%plots real data
et = movementunits(vel, eventtimes);
s = STA(et, lfp, time, binsize);


%finds times when animal is moving and selects randomly from them
mu = movementunits(vel, time);
s = size(s, 2);
ru = randomunits(mu', s); %replace 100 with s

STA(ru, lfp, time, binsize);

f=1;
