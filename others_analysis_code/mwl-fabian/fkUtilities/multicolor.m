function m=multicolor(varargin)
%MULTICOLOR create custom colormap
%
%  m=MULTICOLOR create default length 64 color map ranging from white to
%  black.
%
%  m=MULTICOLOR(colors) create length 64 color map interpolating between
%  specified colors.
%
%  m=MULTICOLOR(colors,x) specifies relative positions of the target
%  colors in the colormap.
%
%  m=MULTICOLOR(...,n) create length n colormap
%

%  Copyright 2007-2008 Fabian Kloosterman

n=64;
colors=[1 1 1; 0 0 0];
coloridx = [0;1];

if nargin>0
  
  if ndims(varargin{1})==2 && size(varargin{1},2)==3 && size(varargin{1},1)>0
    colors = varargin{1};
    coloridx = (1:size(colors,1))';
    if nargin>1
      if numel(varargin{2})==size(colors,1)
        coloridx = varargin{2}(:);
        if nargin>2
          if isscalar(varargin{3}) && varargin{3}>0
            n=varargin{3};
          else
            error('multicolor:invalidArgument', 'invalid third argument')
          end
        end
      elseif isscalar(varargin{2}) && varargin{2}>0
        n=varargin{2};
      else
        error('multicolor:invalidArgument', 'invalid second argument')
      end
    end
  elseif isscalar(varargin{1}) && varargin{1}>0
    n=varargin{1};
  end
end
    
    

if n==1
  m=colors(1,:);
else

  coloridx = (n-1).*(coloridx-coloridx(1))./diff(coloridx([1 end]))+1;
  
  m=interp1(coloridx(:), colors, (1:n)');
end
