function result = calc_cluster_behavior( time, prop_time, props )

result = applyfcn( @(t) applyfcn( @(prop) interp1( prop_time, prop, t, 'nearest'), [], props ),[], time(:) );

