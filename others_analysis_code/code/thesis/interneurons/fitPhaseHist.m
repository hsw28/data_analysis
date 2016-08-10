% Not used, I was just playing here.

function m = fitPhaseHist(x,y)
  m0    = emptyModel();
  iters = 0;
  m     = estimateParams(x,y);
  nIter = 1000;
  while abs(cost(m)-cost(m0)) > 0.001 && iters < nIter
    m0 = m;
    progress = iters/nIter;
    m = optimize(x,y,m,'r_peak',   (1000 * (1-progress)));
    m = optimize(x,y,m,'r_trough', (1000 * (1-progress)));
    m = optimize(x,y,m,'phase',    (6    * (1-progress)));
  end
end

function m = optimize(x,y,m0,f,a)
  
end

function c = cost(xs,ys,m)
  c = sum ((ys-(prediction(xs,m))).^2);
end

function ys = prediction(xs,m)
  x0 = mean([m.r_trough, m.r_peak]);
  a  = diff([m.r_trough, m.r_peak])/2;
  ys = a .* cos(xs - m.phase);
end

function m = emptyModel()
  m.phase    = 0;
  m.r_peak   = 0;
  m.r_trough = 0;
end

function m = estimateParams(x,y)
  m.r_peak   = max(y);
  m.r_trough = min(y);
  m.phase    = x( find(y == max(y), 1, 'first') );
end

function d = modelDist(m0,m1)
  d = sqrt((m0.r_peak - m1.r_peak).^2)/1000 + ...
      sqrt((m0.r_trough - m1.r_trough).^2)/1000 + ...
      sqrt((m0.phase - m1.phase).^2);
end
