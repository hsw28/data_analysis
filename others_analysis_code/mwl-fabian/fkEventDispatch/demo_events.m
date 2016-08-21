function demo_events()
%DEMO_EVENTS demonstrates event notification framework
%
%  DEMO_EVENTS
%

%  Copyright (C) 2006 Fabian Kloosterman
%
%  This program is free software; you can redistribute it and/or modify it
%  under the terms of the GNU General Public License as published by the
%  Free Software Foundation; either version 2 of the License, or (at your
%  option) any later version.
%
%  This program is distributed in the hope that it will be useful, but
%  WITHOUT ANY WARRANTY; without even the implied warranty of
%  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
%  Public License for more details.
%
%  You should have received a copy of the GNU General Public License along
%  with this program; if not, write to the Free Software Foundation, Inc.,
%  59 Temple Place, Suite 330, Boston, MA 02111-1307 USA 


hFig = event_dispatch();

hAx = zeros(4,1);

for k=1:4
  hAx(k) = subplot(2,2,k);
  plot( 1:1000, sin(1:1000), 'Parent', hAx(k) );
end

title( hAx(1), 'Ruler')
title( hAx(2), 'Zoom (shift)')
title( hAx(3), 'Pan (control)')
title( hAx(4), 'Ruler + Zoom + Pan');

ruler( hAx([1 4]), 'TextProps', {'Background', [1 1 1], 'Color', [0 0 0]}, ...
       'LineProps', {'Color', [1 0 0], 'LineStyle', '-'});
scroll_zoom( hAx([2 4]), 'Modifier', 1 );
scroll_pan( hAx([3 4]), 'Modifier', 2 );

tab_axes(hFig);