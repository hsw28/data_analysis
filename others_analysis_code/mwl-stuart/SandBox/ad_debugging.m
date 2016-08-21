fid = fopen('/home/slayton/data.dump');
data = fread(fid, inf, 'float64');
%%
nChannel = 32;
d = reshape(data,nChannel, numel(data)/nChannel);
d = (downsample(d',100))';

%d = (d*10)/(2^16);
for i=1:size(d,1)
    d(i,:) = d(i,:) +i*10;
end

figure; plot(d', 'linesmoothing', 'on');