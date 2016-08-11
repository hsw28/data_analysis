function c = contmap(f,c_in)

c = c_in;
c.data = f(c.data);