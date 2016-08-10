% Script generates a fake traveling wave based on volume conduction from
% two phase-offset sources

t = [0:0.001:1];
f = 8;
offset = pi-pi/6;

source1 = real(exp(i.*2*pi*f.*t));
source2 = real(exp(i.*(2.*pi.*f.*t + offset)));

subplot(2,1,1);
plot(t,source1+2,'b');
hold on
plot(t,source2,'r');

source1_c = [0 0 1];
source2_c = [1 0 1];

n_mix = 10;

mixes = (linspace(1,0,n_mix)'*source1 + linspace(0,1,n_mix)'*source2);
mixes_c = (linspace(1,0,n_mix)'*source1_c + linspace(0,1,n_mix)'*source2_c);

% space the mixes on the y axis
mixes = mixes + repmat([n_mix:-1:1]',1,numel(t));

subplot(2,1,2);
for m = 1:n_mix
    plot(t,mixes(m,:),'Color',mixes_c(m,:));
    hold on;
end