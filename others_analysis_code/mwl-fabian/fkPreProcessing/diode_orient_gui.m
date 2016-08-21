function [m, th] = diode_orient_gui( delta, speed )
%DIODE_ORIENT_GUI explore head direction change
%
%  [m,th]=DIODE_ORIENT_GUI(delta,speed) display histograms of head
%  direction change (delta) and speed. A vertical cursor in the speed
%  histogram allows for chaning the speed threshold. The histogram of
%  head direction change is for those points that have a speed larger
%  than this threshold. Returned are the circular median of the head
%  direction change and the speed threshold.
%


hFig = figure;
hPAx = polaraxes( 'Position', [0.1 0.1 0.3 0.8] );
hAx = subplot(1,2,2);

[speed_hist, speed_hist_x] = hist( speed, 100 );
xlimits = [0 max(speed)];

plot( hAx, speed_hist_x, speed_hist );
title( hAx, 'Unsmoothed speed');
xlim( xlimits);

th = mean(xlimits);
hC = cursor( hAx, th, 0, 'Style', 'vertical'); %#ok

L = handle.listener(hC, hC.findprop('X'), 'PropertyPostSet', @plot_polar); %#ok

hBar=-1;
plot_polar([],[]);

waitfor( hFig )

m = circ_median( delta( speed>=th) );


  function plot_polar(hObj, eventdata) %#ok
    
  th = hC.X;
  
  [n,b] = phasehist( delta( speed>=th), 100 );
  
  if ~ishandle(double(hBar))
    hBar = polarbar( hPAx, b, n, 'LineStyle', 'none');    
  else
    set(hBar, 'RadiusData', n);
  end

  set( hPAx, 'RadialLim', [0 max(n).*1.1] );
  
  end

end