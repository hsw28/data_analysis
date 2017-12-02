function f = struct2matrix(structure)

%converts structure to matrix with NaN values
% good for converting cluster sutrctures
% WORKS


clustname = (fieldnames(structure));
numclust = length(clustname);

maxlen =1;
for f = 1:numclust
  name = char(clustname(f));
    %if length(clusters.(name)) >len
    if length(structure.(name)) >maxlen
        maxlen = length(structure.(name));
    end
end

matrx = zeros(maxlen, numclust);

for f = 1:numclust
    name = char(clustname(f));
    listlength = length(structure.(name));
    padded = padarray(structure.(name), [maxlen-listlength], 'post');
    matrx(:, f) = padded;
end

replace = find(matrx == 0);
matrx(replace) = NaN;

f = matrx;
