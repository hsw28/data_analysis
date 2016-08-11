function [dists] = get_field_dists(fieldSources,fields,fieldClusts,varargin)

p = inputParser();
p.addParamValue('method', 'peak', @(x) any(strcmp(x, {'peak', 'xcorr'})));
p.addParamValue('min_peak_rate_thresh', 15);
p.addParamValue('rate_thresh_for_multipeak',5);
p.addParamValue('multipeak_max_spacing',0.5);
p.addParamValue('max_abs_field_dist',1);
p.addParamValue('okMatrix', ones(numel(fields),numel(fields)));
p.addParamValue('draw',false);
p.parse(varargin{:});
opt = p.Results;

binCenters = fieldClusts{1}.field.bin_centers;
binCenters = [binCenters, [binCenters(end:-1:1)]]; % unwrap inbound space
if(numel(fields) ~= numel(fieldClusts))
    error('get_field_dists:bad_place_cells_list',['Trying to use place_cells,' ...
        ' but it hasn''t yet been indexed by fieldSources']);
end

dists = zeros(numel(fields),numel(fields));
if (strcmp(opt.method,'peak'))
    for r = 1:numel(fields)
        for c = 1:numel(fields)
            if(~opt.okMatrix(r,c))
                dists(r,c) = NaN;
            else
              dists(r,c) = distByPeak(binCenters,fields{r},fields{c});
              if( abs(dists(r,c)) > opt.max_abs_field_dist )
                dists(r,c) = NaN;
              end
              dists(c,r) = -1 * dists(r,c);
            end
        end
    end
elseif(strcmp(opt.method,'xcorr'))
    for r = 1:numel(fields)
        for c = (r+1):numel(fields)
          dists(r,c) = distByXcorr(binCenters,fields{r},fields{c});  
        end
    end
else
        error('get_field_dists:method_opt_impossible',...
            'Impossible case');
end

if(opt.draw)
    subplot(1,2,1);
    lfunDraw(fieldClusts,fields,fieldSources,dists);
    subplot(1,2,2);
    colormap('cool');
    imagesc(dists);
end

end

function dist = distByPeak(binCenters,fieldA,fieldB)
    midInd = floor(numel(binCenters)/2)+1;
    binCenters(midInd:end) = binCenters(1:(midInd-1));
    peakB = binCenters(find(fieldB == max(fieldB),1,'first'));
    peakA = binCenters(find(fieldA == max(fieldA),1,'first'));
%    warning('check comment on next line is true');
    dist = peakA - peakB;  % Distance from B forward to A matches xcorr semantics
end

function dist = distByXcorr(binCenters,fieldA,fieldB)
    db = binCenters(2) - binCenters(1);
    maxb = 2; % 1 meter max lag
    nLags = ceil(maxb / db);
    lagb = [-nLags.*db : db : nLags*db];
    peakA = binCenters( find(fieldA == max(fieldA),1,'first'));
    peakB = binCenters( find(fieldB == max(fieldB),1,'first'));
    if abs(peakB - peakA ) < 1
        x = xcorr(fieldA,fieldB,nLags);
        dist = lagb( find(x == max(x),1,'first'));
    else
        dist = sign(peakB - peakA) * 1;
    end
end

function f = lfunDraw(place_cells,fields,fieldLabels,distsMat)
    bin_centers = place_cells.clust{1}.field.bin_centers;
    
    isDiffName = [0, 1 - strcmp(fieldLabels(1:(end-1)), fieldLabels(2:end))];
    baselines = cumsum(isDiffName);
    colorInd = 1:numel(baselines); % doesn't do what I want
    
    for n = 1:numel(fields)
        area(bin_centers, fields{n} ./ max(fields{n}) + baselines(n) - 1,...
            baselines(n) - 1,'FaceColor',gh_colors(colorInd(n))); hold on;
    end
end
