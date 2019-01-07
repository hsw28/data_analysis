function f = triggerpos2quad(xval, yval)
%takes triggered output from STAdecoded.m and divides it into 10 regions using posdistro.m


size(xval)
distro = zeros(size(xval));
size(distro)
for n = 1:size(xval,1)
  d = posdistro([xval(n,:); yval(n,:)]);
  distro(n,:) = d;
end

f = distro;
distro2 = zeros(10, size(distro,2));
for n = 1:size(distro,2)
  for j = 1:10
      want = find(distro(:,n)==j);
      distro2(j,n) = length(want)./size(distro,1);
    end
end

figure
for j = 1:10
  plot(distro2(j,:), 'LineWidth',1.5)
  str1 = {j};
  [n mx] = (max(distro2(j,:)))
  if length(mx) > 0
    text(mx(1), max(distro2(j,:)), str1);
  end
  hold on
end
xlabel('Seconds around trigger')
ylabel('Percent decoded in location')
vline(round(length(distro2))/2)
xticks(0:round(length(distro2))/2:round(length(distro2)))
xticklabels({-.25 , 0, .25'})
