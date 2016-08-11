function rpS = smoothRpos(rp,varargin)

p = inputParser();
p.addParamValue('stdTime',0.015);
p.addParamValue('stdPos',0.05);
p.addParamValue('rangeTime',0.05);
p.addParamValue('rangePos',0.5);
p.parse(varargin{:});
opt = p.Results;

dx = (rp(1).tend - rp(1).tstart)/(size(rp(1).pdf_by_t,2));
%dy = rp(1).x_vals(2) - rp(1).x_vals(1);
dy = diff(rp(1).x_range) / (size(rp(1).pdf_by_t,1));

k = makeKernel2(opt.stdTime,opt.stdPos,opt.rangeTime,opt.rangePos,dx,dy);

rpS = rp;

for c = 1:numel(rpS)
  rpS(c).pdf_by_t = conv2(rp(c).pdf_by_t,k,'same');
end