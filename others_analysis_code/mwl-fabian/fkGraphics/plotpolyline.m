function h = plotpolyline(nodes,varargin)
%PLOTPOLYLINE plot a polyline
%
%  h=PLOTPOLYLINE(nodes) plots a polyline defined by the nx2 matrix and
%  returns a handle.
%
%  h=PLOTPOLYLINE(struct) plots a polyline defined by the structure.
%
%  h=PLOTPOLYLINE(...,arg1,arg2,...) passes extra arguments to the line
%  function that is used to plot the polyline.
%

if nargin<1
  help(mfilename)
  return
end

if isnumeric(nodes) && size(nodes,2)==2 && size(nodes,1)>0
  h = line( nodes(:,1), nodes(:,2), varargin{:} );
elseif isstruct(nodes) && isfield(nodes, 'nodes') ...
      && isnumeric(nodes.nodes) && size(nodes.nodes,2)==2 && ...
      size(nodes.nodes,1)>0
  
  if isfield(nodes,'isclosed') && nodes.isclosed
    nodes.nodes = nodes.nodes([1:end 1],:);
  end
  
  if isfield(nodes,'isspline') && nodes.isspline
    pnts = fnplt( cscvn( nodes.nodes' ) );    
    h = line( pnts(1,:), pnts(2,:), varargin{:} );
  else
    h = line( nodes.nodes(:,1), nodes.nodes(:,2), varargin{:} );
  end
else
  error('plotpolyline:invalidArgument', 'Invalid polyline')
end
  
