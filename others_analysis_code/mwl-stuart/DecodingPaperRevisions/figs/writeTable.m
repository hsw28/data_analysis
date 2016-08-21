function writeTable(colName, rowName, data, file)

fid = fopen(file,'w+');

if numel(rowName)~= size(data,1)
    error;
elseif numel(colName)~=size(data,2);
    error;
end

fprintf(fid, 'XX, ');
for j = 1:size(data,2)
    fprintf(fid, '%s', colName{j});
    if j < size(data,2)
        fprintf(fid,', ');
    else
        fprintf(fid, '\n');
    end
end

for i = 1:size(data,1);
    fprintf(fid, '%s, ', rowName{i});
    for j = 1:size(data,2);
        fprintf(fid, '%f', data(i,j));
        if j < size(data,2)
            fprintf(fid,', ');
        else
            fprintf(fid,'\n');
        end
    end
end

fclose(fid);

end