function demo_event2seg()
%DEMO_EVENT2SEG demonstrate event2seg function
%
%  DEMO_EVENT2SEG
%

%  Copyright 2007-2007 Fabian Kloosterman


event1 = [1 3 6 9 13 17 21 25 29 35 40];
event2 = [4 8 14 23 32 34 38];

seg1 = event2seg( event1, event2, 'GreedyStart', 0, 'GreedyEnd', 0 );
seg2 = event2seg( event1, event2, 'GreedyStart', 1, 'GreedyEnd', 0 );
seg3 = event2seg( event1, event2, 'GreedyStart', 0, 'GreedyEnd', 1 );
seg4 = event2seg( event1, event2, 'GreedyStart', 1, 'GreedyEnd', 1 );

hFig = figure; %#ok
hAx = axes;

line( [event1;event1], [0;7], 'Color', [0 0 1], 'LineStyle', ':' );
line( [event2;event2], [0;7], 'Color', [1 0 0], 'LineStyle', ':' );
line( [event1;event1], [5.6;6.4], 'Color', [0 0 1] );
line( [event2;event2], [4.6;5.4], 'Color', [1 0 0] );
line( seg1', [4;4], 'Color', [0 0 0] );
line( seg2', [3;3], 'Color', [0 0 0] );
line( seg3', [2;2], 'Color', [0 0 0] );
line( seg4', [1;1], 'Color', [0 0 0] );

set(hAx, 'YLim', [0 7], 'XLim', [0 55] );

text( 42, 6, {'ON event'}, 'Parent', hAx )
text( 42, 5, {'OFF event'}, 'Parent', hAx )
text( 42, 4, {'GreedyStart=0', 'GreedyEnd=0'}, 'Parent', hAx )
text( 42, 3, {'GreedyStart=1', 'GreedyEnd=0'}, 'Parent', hAx )
text( 42, 2, {'GreedyStart=0', 'GreedyEnd=1'}, 'Parent', hAx )
text( 42, 1, {'GreedyStart=1', 'GreedyEnd=1'}, 'Parent', hAx )

title( hAx, 'Demo event2seg' );