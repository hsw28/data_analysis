function yhat = mymodel(beta,x)
    yhat = beta(1) * x(:,1).^2 + beta(2)*x(:,1) + beta(3);