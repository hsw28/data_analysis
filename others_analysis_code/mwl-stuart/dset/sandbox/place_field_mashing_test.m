cl = dset.clusters;

pfEdges = cl(1).pf_edges;

pfIdx = [pfEdges(1,1):pfEdges(1,2), pfEdges(2,1):pfEdges(2,2)];


pf1 = cell2mat({cl.pf});


pf2 = [];
for i = 1:numel(cl)
    pf2(:,i) = cl(i).pf(pfIdx);
end

%%

a = ones(5);

for i = 1:5
    a(:,i) = i*10;
end
for i = 1:5
    a(i,:) = a(i,:) +i;
end

for i = 1:5
    a(:,i) = circshift(a(:,i), randi(size(a,2)));
end


aNew = a(1+m*J+mod(bsxfun(@minus, I, 
%%
idx = randsample(5,5);
a = a(:,idx);