function f = spiketrainCC(structureofspikes, spikestocompare, time)
%time can be anyformat, just used to establish start and end times

spikestocompare = spiketrain(spikestocompare, time, .005);
f = spikestocompare;
spikenames = fieldnames(structureofspikes);
spikenum = length(spikenames);
plots = ceil(spikenum./3);

output = {'cluster name'; '# spikes'; 'CC'};

maxcc = [];
for k=1:spikenum
    name = char(spikenames(k));
    currentcluster = structureofspikes.(name);

    clusterST= spiketrain(currentcluster, time, .005);
    %subplot(plots, 3, k);
    x = crosscorr(spikestocompare, clusterST, 'NumLags', 200);
    maxcc = max(x(170:230));
    newdata = {name; length(currentcluster); maxcc};
    output = horzcat(output, newdata);
end

f = output';
