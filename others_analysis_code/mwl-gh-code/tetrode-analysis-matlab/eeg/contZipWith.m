function c = contZipWith(f,c1,c2)

c = c1;
c.data = f(c1.data,c2.data);