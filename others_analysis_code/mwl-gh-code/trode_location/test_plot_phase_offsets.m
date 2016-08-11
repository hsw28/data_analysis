function test_plot_phase_offsets()

t = [0:pi/1000:100]';
t1 = t + pi./200.*randn(size(t));
t2 = t + pi./200.*randn(size(t));
omega = 10*2*pi;

x1 = sin(t1.*omega);
x2 = sin(t2.*omega + 0.5);

cdat = imcont('timestamp',t,'data',[x1,x2]);
cdat.data = double(cdat.data);
theta_fo = filtoptdefs('theta'); theta_fo.Fs = cdat.samplerate;
theta_filt = mkfilt('filtopt',theta_fo); cdat_theta = contfilt(cdat,'filt',theta_filt);
phase = multicontphase(cdat_theta);
gh_plot_cont(phase);

figure;
%subplot(2,1,1); plot(t,x1,t,x2); legend({'x1','x2'})

dphase = gh_circular_subtract(phase.data(:,2),phase.data(:,1));
plot(conttimestamp(phase),dphase)
figure; rose(dphase)