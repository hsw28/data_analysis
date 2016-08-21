d = load(mwlopen('/home/slayton/data/spl11/day15/t08/t08.tt');
%%
ts = d.timestamp/10000;

idx = ts>4000 & ts < 4200;

d.timestamp = d.timestamp(idx);
d.waveform = d.waveform(:,:,idx);


fields = {'timestamp', 'waveform'};
types = {'int32', 'int32'};
size = {1, 4*32};

%%
mwlFields = mwlfield(fields, types, size);

outfile = '/home/slayton/src/mwsoft64/test.tt';
%%
f = mwlcreate(outfile, 'waveform', fields', mwlFields, ...
            'FileFormat', 'binary', 'Mode', 'overwrite', ...
             'Data', d);
