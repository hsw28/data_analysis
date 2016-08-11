function [fields,fieldSources,unwrappedPlaceCells] = get_fields(place_cells,varargin)

p = inputParser();
p.addParamValue('ok_directions',{'outbound','inbound'});
p.addParamValue('min_boundary_edge_dist',0);
p.addParamValue('min_peak_edge_dist',0.05);
p.addParamValue('method', 'peak', @(x) any(strcmp(x, {'peak', 'xcorr'})));
p.addParamValue('min_peak_rate_thresh', 10);
p.addParamValue('edge_rate_thresh',0.5);
p.addParamValue('rate_thresh_for_multipeak',5);
p.addParamValue('multipeak_max_spacing',0.5);
p.addParamValue('max_abs_field_dist',2);
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

fields = cell(0);
fieldSources = cell(0);

for c = 1:numel(place_cells.clust)
    place_cells.clust{c} = unrollOutboundInbound(place_cells.clust{c},opt);
    workingClust = place_cells.clust{c};
    nCellField = 0;
    while hasField(workingClust,opt)
        [thisField,workingClust] = lfunTakeTopField(workingClust,opt);
        fields = [fields, thisField];
        nCellField = nCellField + numel(thisField);
    end
    fieldSources = [fieldSources, cmap(@(x) workingClust.name, cell(1,nCellField))];
    xs = workingClust.field.bin_centers;
end

keep = cellfun(@(r) okBoundaries(xs,r,opt), fields);
fields       = fields(keep);
fieldSources = fieldSources(keep);

unwrappedPlaceCells = sdatslice(place_cells,'names',fieldSources);
for n = 1:numel(unwrappedPlaceCells.clust)
    unwrappedPlaceCells.clust{n}.field.rate = fields{n};
end

end

function edges = mergeNeighbors(fieldEdges,xs,fieldRate,opt)
    isClean = true;
    edges = fieldEdges;
    nSubfields = numel(fieldEdges)-1;
    for n = 2:nSubfields
        prevRange = [fieldEdges(n-1),fieldEdges(n)  ];
        nextRange = [fieldEdges(n),  fieldEdges(n+1)];
        bigRange = [prevRange(1),nextRange(2)];
        lastX = xs(floor(numel(xs)/2));
        isOk = @(r) ...
            ((max(fieldRate(xs >= r(1) & xs <= r(2))) >= ...
            opt.min_peak_rate_thresh));
        %if(~all(size(bigRange) == [1,2])) || (~all(size(prevRange) == [1,2])) || (~ all(size(nextRange) == [1,2])) || numel(lastX) == 1
        %    a =1
        %end
        if (~isOk(prevRange) || ~isOk(nextRange)) && ...
                (sign(lastX - bigRange(1)) == ...
                 sign(lastX - bigRange(2)))
            edges(n) = NaN;  % Flag for removal
            isClean = false;
        end
    end
    if ~isClean
        edges = edges(~isnan(edges));
        edges = mergeNeighbors(edges,xs,fieldRate,opt);
    end
end

%function clustNew = unfoldBinCenters(clust)
%    field = unwrap_linear_field(clust.field);
%    clustNew = clust;
%    clustNew.field = field;
%end

function newClust = unrollOutboundInbound(clust,opt)
    newClust = clust;
    field = unwrap_linear_field(newClust.field,...
            'ok_directions',opt.ok_directions);
    newClust.field = field;
end

function b = okBoundaries(xs,rates,opt)

    fieldEdges = [min(xs(rates>0)), max(xs(rates>0))];
    xMid = xs(floor( numel(xs)/2));
    okBoundaries = ...
        all( abs(fieldEdges - min(xs)) >= opt.min_boundary_edge_dist) & ...
        all( abs(fieldEdges - max(xs)) >= opt.min_boundary_edge_dist) & ...
        all( abs(fieldEdges - xMid) >= opt.min_boundary_edge_dist );
    fieldPeaks = xs(rates == max(rates));
    okPeaks = all( abs(fieldPeaks - min(xs)) >= opt.min_peak_edge_dist) & ...
              all( abs(fieldPeaks - max(xs)) >= opt.min_peak_edge_dist) & ...
              all( abs(fieldPeaks - xMid) >= opt.min_peak_edge_dist);

          
    b = okBoundaries & okPeaks;
end


% This guy was written to return 1 field, but I'd like it to return
% possibly more, if that one has a deep valley that should split the
% field into two parts. Really ought to use phase here to break
function [topFields,adjClust] = lfunTakeTopField(clust,opt)
    if strcmp(clust.name,'cell_2323_cl-2')
        a = 1;
    end
    cRate = clust.field.rate;
    xs = clust.field.bin_centers;
    topField = zeros(size(cRate));
    isValid = true;
    adjClust = clust;
    peakP = clust.field.bin_centers(cRate == max(cRate));
    peakP = peakP(1);
    iPeak = find(cRate == max(cRate),1,'first');
    i = iPeak;
    while i <= numel(cRate) && cRate(i) > opt.edge_rate_thresh
        topField(i) = cRate(i);
        cRate(i) = 0;
        i = i + 1;
    end
    i = iPeak - 1;
    while i >= 1 && cRate(i) > opt.edge_rate_thresh
        topField(i) = cRate(i);
        cRate(i) = 0;
        i = i - 1;
    end

    % Pad to help with onset-at-edge cases
    dx = xs(2) - xs(1);
    xs = [xs(1)-dx, xs, xs(end)+dx];
    topField = [0, topField, 0];

    adjClust.field.rate = cRate;
    fieldEdges = xs(diff(topField > 0) ~= 0) + dx;
    
    % Undo the padding
    xs = xs(2:(end-1));
    topField = topField(2:(end-1));
    
    fieldEdges = ...
        [fieldEdges(1), ...
         xs(topField < opt.rate_thresh_for_multipeak & localMins(topField)),...
         fieldEdges(end)];
    fieldEdges = mergeNeighbors(fieldEdges,xs,topField,opt);
    nFields = numel(fieldEdges) - 1;
    topFields = cell(1,nFields);
    for n = 1:nFields
        thisField = zeros(size(cRate));
        thisKeep = xs >= fieldEdges(n) & xs <= fieldEdges(n+1);
        thisField(thisKeep) = topField(thisKeep);
        topFields{n} = thisField;
    end
    topFields = filterCell(@(x) (max(x) > opt.min_peak_rate_thresh), ...
                           topFields);
end

function b = hasField(clust,opt)
    b = max(clust.field.rate) > opt.min_peak_rate_thresh;
end

function ms = localMins(xs)
  ms = [0, ...
       (xs(2:(end-1)) < xs(1:(end-2)) & xs(2:(end-1)) < xs(3:end)),...
       0];
end