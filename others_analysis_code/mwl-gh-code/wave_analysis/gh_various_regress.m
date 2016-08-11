%% Rergesses
good_ind = beta_data_sleep.r_squared > 0.6;
good_ind2 = beta_data_sleep.est(2,:) < 30;
good_ind3 = beta_data_sleep.est(2,:) > 0;
%good_ind4 = abs(beta_data.vel) > 0.1;
%good_ind2 = abs(beta_data.vel) > 0.1;
good_ind = and(good_ind,good_ind2);
good_ind = and(good_ind,good_ind3);
%good_ind = and(good_ind,good_ind4);
%good_ind = beta_data.est(5,:) > 0;
%good_ind2 = beta_data.est(2,:) < 40;
%good_ind3 = beta_data.est(2,:) > 0;
%good_ind = and(good_ind,good_ind2);
%good_ind = and(good_ind,good_ind3);

%wave_speed = beta_data.est(1,:) .* beta_data.est(2,:);

%dv = wave_speed(good_ind);
%iv = abs(beta_data.vel(good_ind));
%iv(iv > pi) = iv(iv > pi) + -2*pi;
iv = beta_data_sleep.est(2,good_ind);
%dv = abs(beta_data_sleep.est(2,good_ind));
dv = mod(beta_data_sleep.est(3,good_ind)+pi, 2*pi);
figure;

x = [ones(size(iv))',iv'];
y = dv';

gh_scatter_image(iv,dv);

[b,bint,r,rint,stats] = regress(y,x);

hold on

xi = [min(iv),max(iv)];
yi = b(1) + b(2).*xi;
plot(xi,yi,'w');

%% Distributions

good_ind = beta_data.r_squared > 0.5;

%data = beta_data.est(5,good_ind);
%data = [data, data - 2*pi];
data = mod(beta_data.est(3,good_ind)+pi,2*pi) - pi;

%good_ind = data > -pi;
%good_ind2 = data < pi;

%good_ind = and(good_ind, good_ind2);
%data = data(good_ind);

edges = linspace(-2*pi,2*pi,50);
counts = histc(data,edges);

figure;
h = area(edges,counts./sum(counts));
set(h,'LineWidth',3);
set(h,'FaceColor',[0 1 0]);

hold on;

good_ind = beta_data_sleep.r_squared > 0.7;

%data2 = beta_data_sleep.est(5,good_ind);
data2 = beta_data_sleep.est(3,good_ind);
%data2 = [data2, data2 - 2*pi];

%good_ind = data2 > -pi;
%good_ind2 = data2 < pi;

%good_ind = and(good_ind, good_ind2);
%data2 = data2(good_ind);

counts2 = histc(data2,edges);
h = area(edges,counts2./sum(counts2));
set(h,'LineWidth',3);
set(h,'FaceColor',[0 0 1]);

h = plot(edges,counts./sum(counts));
set(h,'LineWidth',3);
set(h,'Color',[0 0 0]);
