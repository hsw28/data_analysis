function npts = oat2pos(inputfile,outputfile)

formatspec = '%f %f %f %f %f';
sizespec = [3, Inf];

fileID = fopen(inputfile,'r');

if fileID ~= -1
    arrayin = fscanf(fileID,formatspec, sizespec);
    fclose(fileID);
else
    error('Could not open input file')
end

binfile = fopen(outputfile,'w');
npts = size(arrayin,2);

for k = 1: npts
	% timestamp
	time = arrayin(1,k)./10000;
	fwrite(binfile,time,'float');
	%fwrite(binfile,(arrayin(1,k)),'float');
	% pos x1
	fwrite(binfile,arrayin(2,k),'float');
	% pos y1
	fwrite(binfile,arrayin(3,k),'float');
	% pos x2
	fwrite(binfile,arrayin(2,k),'float');
	% pos y2
	fwrite(binfile,arrayin(3,k),'float');
end
fclose(binfile);
