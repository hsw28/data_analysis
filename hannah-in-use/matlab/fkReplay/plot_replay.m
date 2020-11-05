function plot_replay( Rinfo, target, varargin )


options = struct( 'parent', [] );
options = parseArgs(varargin, options );

if isempty(options.parent)
  hFig = figure; %#ok
  hAx = axes;
elseif ~ishandle(options.parent) || ~strcmp(get(options.parent,'Type'),'axes')
  error('plot_replay:invalidArgument', 'Invalid axes handle')
else
  hAx = options.parent;
end

posgrid = eval( Rinfo.posgrid );
ybins = [mean(posgrid(1:2)) mean(posgrid((end-1):end))];

maxwidth = diff( target.segment, 1, 2) ./ 2;

e2c = @(x) 1- cat(3, x(:,:,1), sum(x,3), x(:,:,end) );

imagesc( 1000*([0.5 -0.5].*Rinfo.timebin + target.segment - mean(target.segment)), ...
           ybins/100, e2c(target.estimate), 'parent', hAx );

set( hAx, 'XLim', 1000*[-maxwidth maxwidth], ...
             'CLim', [0 1], 'YLim', [0 1050]/100, 'YDir', 'normal');

axes(hAx);

hL = line( 1000*repmat((-(target.nbins/2):(target.nbins/2)).*Rinfo.timebin ,2,1), repmat([0; ...
                    1050],1,size(target.estimate,2)+1) );
set(hL, 'linewidth', 2, 'color', [0.9 0.9 0.9]);

 
[px,py]=line2patch( (target.linetime-mean(target.segment))*1000, ...
                    target.linepos/100, 0.25 );

patch( px, py, [1 0.75 1], 'FaceAlpha', 0, 'EdgeColor', [0.5 0.375 0.5], ...
       'LineStyle', '- -');
