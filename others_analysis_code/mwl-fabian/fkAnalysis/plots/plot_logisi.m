function varargout = plot_logisi( varargin )
%PLOT_LOGISI plot histogram of log inter spike interval
%
%  Syntax
%
%      h = plot_logisi( ... )
%
%  Description
%
%    This function will accept the same input arguments as ISI and will
%    plot a histogram of log(isi).
%

% Copyright 2006-2006 Fabian Kloosterman


%compute isi
i = isi( varargin{:} );
log_i = log10(i(:)');

%create figure
h = figure;
hAx = axes;

nbins = 50;

edges = linspace( log10(0.0005), log10(100), nbins+1 );
bins = histc(log_i, edges);

xx = [edges(1:end-1) ; edges(2:end) ; edges(2:end) ; edges(1:end-1)];
yy = [zeros(1,nbins) ; zeros(1,nbins) ; bins(1:end-1) ; bins(1:end-1)];

patch(xx, yy, [0 0 1], 'LineStyle', 'none', 'Parent', hAx);

ylabel(hAx, '# intervals')
xlabel(hAx, 'inter spike interval (s)')

title(hAx, 'Log ISI histogram', 'FontSize', 12);

set(hAx, 'XTick', [-4:2], 'XTickLabel', cellstr( num2str( 10.^[-4:2]' ) ) );

if nargout>=1
    varargout{1} = h;
end