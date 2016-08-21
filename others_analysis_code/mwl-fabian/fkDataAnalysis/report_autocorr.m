function report_autocorr( clusters , varargin )

args = struct( 'Parent', [], 'Lag', 0.025, 'NBins', 101, 'Segments', [-Inf Inf], 'RemoveZero', 0, 'Method', 'histogram', 'BandWidth', [] );
args = parseArgs( varargin, args );

if isempty(args.Parent)
    args.Parent = gcf;    
elseif ishandle(args.Parent) && ismember( get(args.Parent, 'Type'), {'figure', 'uipanel'} )
    %pass
else
    error('Invalid parent')
end

% make NBins odd
if mod( args.NBins, 2 ) == 0
    args.NBins = args.NBins + 1;
end

if isempty(args.BandWidth)
    args.BandWidth = args.Lag ./ 100;
end

ncl = numel( clusters );
ncols = 5;
nrows = ceil( ncl ./ ncols );

%h = axismatrix(nrows, ncols, ncl, 'Parent', args.Parent)';
h = layoutmanager(args.Parent, nrows, ncols, 'YOffset', 3, 'YSpacing', 3, ...
                  'XOffset', 2, 'XSpacing', 2);

edges = linspace( -args.Lag, args.Lag, args.NBins );


for k=1:ncl
    
    c = eventcorr( clusters(k).timestamp, [], -args.Lag, args.Lag, args.Segments );
    
    if args.RemoveZero
        c = c(c~=0);
    end    
    
    axes( h(k) );
    
    if strcmp(args.Method, 'histogram')
        b = histc( c, edges );
        p = patch( [edges(1:end-1) ; edges(2:end) ; edges(2:end) ; edges(1:end-1)], [ repmat( 0, 2, numel(edges)-1 ) ; b(1:end-1)' ; b(1:end-1)'  ], [0 0 0] );
    else
      xx = linspace(edges(1), edges(end), 1000);
      b = ksdensity( c, xx, 'Width', args.BandWidth );
      p = line( xx, b, 'Color', [0 0 0]);
    end
       
    title( h(k),  ['TT' num2str( clusters(k).tetrode, '%2d' ) '-' num2str( clusters(k).cluster_id, '%2d' ) ' ' num2str(k, '%2d')] );
    
end

set( h(~isnan(h(:))), 'XLim', [-args.Lag args.Lag] );