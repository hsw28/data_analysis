function est = smooth_estimate(est)
 est = smoothn(est,3,'kernel', 'my_kernel', 'my_kernel', [1;1;1]);
end