function cent = edges2centers(edges)

dEdge = diff(edges);
if ~all( dEdge == mean(dEdge));
    warning('Edges must be evenly spaced');
end
dEdge = mean(dEdge);

cent = edges(1:end-1) + dEdge/2;

end