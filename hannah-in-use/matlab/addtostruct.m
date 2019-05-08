function f = addtostruct(structure, amounttoadd)

spikenames = fieldnames(structure);
spikenum = length(structure);

for k = 1:spikenum
  name = char(spikenames(k));
  structure.(name) = structure.(name)+amounttoadd;
end

f = structure;
