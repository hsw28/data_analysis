function f = eventunits(units, LSevent)
%events must be in format start,stop,start,stop,etc
% outputs a vector of spikes that occur during LSevents

if size(units,2)>size(units,1)
    units = units';
end

if size(LSevent,2)<size(LSevent,1)
    LSevent = LSevent';
end

i = 1;
spikeunits = [];
while i <= size(LSevent,2)
  starting = LSevent(1,i); %start
  ending = LSevent(1,i+1); %end
  x = find(units>starting & units<ending);
  newunits = units(x);
  newunits = newunits';
  spikeunits=[spikeunits, newunits];
i = i+2;
end

f = spikeunits;
