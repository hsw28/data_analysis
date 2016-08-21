function varargout = plot_csi( varargin )
%PLOT_CSI pretty plot of complex spike index
%
%  Syntax
%
%      h = plot_csi( events, ... )
%
%  Description
%
%    Plot the csi and cross-csi for a group of spike trains. Argument
%    events is a cell array of event times vectors. The function returns
%    the figure handle h. This function accepts the same imput arguments as
%    CSI
%

% Copyright 2005-2005 Fabian Kloosterman

args = struct( 'Parent', []);
[args,other] = parseArgs( varargin, args );

if isempty(other)
    return
else
    %compute csi
    csival = csi( other{:} );
end

%create figure
if isempty(args.Parent)
    hAx = gca;    
elseif ishandle(args.Parent) && strcmp( get(args.Parent, 'Type'), 'axes')
    hAx = args.Parent;
elseif ishandle(args.Parent) && ismember( get(args.Parent, 'Type'), {'figure', 'uipanel'} )
    hAx = axes('Parent', args.Parent);
else
    error('Invalid parent')
end

[r,c] = size( csival );

%plot image
hImg = imagesc( csival, [-50 50] );
colormap jet;

%axis labels
ylabel('spike train');
xlabel('reference spike train');

%axis ticks
set(hAx, 'XTick', 1:c, 'YTick', 1:r);

%display colorbar
hC = colorbar;
ylabel(hC, 'complex spike index');

%plot text
hTxt = zeros(r,c);
for j = 1:r
    for k = 1:c
        hTxt(j,k) = text( k, j, num2str(csival(j,k), '%0.1f'), 'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', 'FontSize', 8, 'HitTest', 'off');
    end
end


title(hAx, 'Complex Spike Index Matrix', 'FontSize', 12);

cmenu = uicontextmenu();
set( hImg, 'UIContextMenu', cmenu);
uimenu( cmenu, 'Label', 'show/hide text', 'Callback', @(h,e) set(hTxt, 'Visible', onoff( strcmp( get(hTxt(1), 'Visible'), 'off' ) ) ) );

if nargout>=1
    varargout{1} = hAx;
end