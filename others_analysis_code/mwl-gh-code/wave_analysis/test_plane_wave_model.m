x_pos = [0:0.2:10];
y_pos = [0:-0.2:-10];
t = [0:0.005:1];
%t = 0:3;

[X,Y,T] = meshgrid(x_pos,y_pos,t);

freq = 8;
lambda = 10;
theta = -pi/3;
theta = 0;
phase_not = 0.7;
amp = 0.1;

%test_time = t;

Beta = [freq, lambda, theta, phase_not, amp];

% x here is the independent variable array.  Not x_pos itself.

%x = [reshape(T(T == test_time),[],1),...
%    reshape(X(T == test_time),[],1),...
%    reshape(Y(T == test_time),[],1)];

x = [reshape(T,[],1),reshape(X,[],1),reshape(Y,[],1)];

yhat = plane_wave_model(Beta,x,'draw',true,'fps',40);