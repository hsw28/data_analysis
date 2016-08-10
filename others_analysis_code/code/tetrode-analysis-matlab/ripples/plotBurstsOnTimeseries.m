function plotBurstsOnTimeseries(bursts,offset,scale)

cellfun(@(x) lfun_plot_one_arity(x,offset,scale), bursts);

end

function lfun_plot_one_arity(this_arity,offset,scale)
if(numel(this_arity) > 0)
    thisY = (numel(this_arity{1})-1) * scale + offset;
    cellfun(@(x) plot(x, thisY*ones(size(x)),'.'), this_arity);
end
end