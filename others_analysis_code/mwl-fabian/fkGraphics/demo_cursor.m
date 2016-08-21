function demo_cursor
%DEMO_CURSOR shows off cursor and rangecursor
%
%  DEMO_CURSOR Creates a new figure with subplots and cursors in each
%  subplots. Also demonstrates linking between cursors.
%

hFig = figure; %#ok

hC = handle([]);

h(1,1) = subplot(2,2,1);
hC(1,1) = cursor(h(1,1), 0.5, 0.5, 'Style', 'vertical');

h(1,2) = subplot(2,2,2);
hC(1,2) = cursor(h(1,2), 0.5, 0.5);

h(2,1) = subplot(2,2,3);
hC(2,1) = rangecursor(h(2,1), [0.25 0.75], [0.25 0.75], 'Style', 'horizontal');

h(2,2) = subplot(2,2,4);
hC(2,2) = rangecursor(h(2,2), [0.25 0.75], [0.25 0.75]);

set(h, 'XLim', [0 1], 'YLim', [0 1]);

L(1) = linkprop( hC(2,:), 'YLim' );
L(2) = linkprop( hC([2 3 4]), 'Y');
L(3) = linkprop( hC([1 3 4]), 'X');

%store link objects
setappdata( hFig, 'linkedprops', L);