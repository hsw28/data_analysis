function yi = gh_interp_floor(x,y,xi)

  % yi are values taken from function y = f(x)
  % 'interpolation' method is, track back to 'floor' closest index

  if(not(all(size(x) == size(y))))
    error('x and y same size, please!');
end

  [tmp,ind] = sort(x);
x = x(ind);
y = y(ind);


  old_size_xi = size(xi);

  x = reshape(x,1,[]);
y = reshape(y,1,[]);
xi = reshape(xi,[],1);

yi = zeros(size(xi));
for m = 1:numel(xi)
x_g_xi = x > xi(m);
if(max(x_g_xi)==0)
  yi(m) = y(numel(y));
elseif(min(x_g_xi)==1)
yi(m) = NaN;
 else
   yi(m) = y(find(diff(x_g_xi)));
end
end
yi = reshape(yi,old_size_xi);
