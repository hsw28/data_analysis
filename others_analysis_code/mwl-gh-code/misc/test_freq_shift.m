n = [0:0.01:1];
f1 = 1;
x_n = exp(i.*f1.*(2*pi).*n);
x_n = mod(n,0.5);

f0 = -2;
y_n = exp(i.*f0.*(2*pi).*n) .* x_n;

subplot(2,1,1);
plot3(n,real(x_n),imag(x_n));
xlabel('x');ylabel('y');zlabel('z');

subplot(2,1,2);
plot3(n,real(y_n),imag(y_n));
xlabel('x'),ylabel('y'),zlabel('z');