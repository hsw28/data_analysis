function x = circspace(start_x, stop_x, n_x)

dx = (stop_x - start_x)/n_x;

x = (start_x) : dx : (stop_x - dx);