function m = mapMap(f, m0)

vs0 = m0.values();
ks  = m0.keys();

vs = cmap(f,vs0);

m = containers.Map(ks,vs);