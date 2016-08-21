function setLegendInfo(this)
%SETLEGENDINFO Set legendinfo
%
%  SETLEGENDINFO(h)
%
 
%  Copyright 2008-2008 Fabian Kloosterman

setLegendInfo(this.hScatter);

setappdata(double(this),'LegendLegendInfo',getappdata(this.hScatter,'LegendLegendInfo'));
  
setappdata(double(this),'LegendLegendType','patch');