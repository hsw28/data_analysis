function disp_now()

time = fix(clock);
if time(6)>10
    disp(['It is: ', num2str(mod(time(4),12)), ':', num2str(time(5)), ':', num2str(time(6))]);
else
    disp(['It is: ', num2str(mod(time(4),12)), ':', num2str(time(5)), ':0', num2str(time(6))]);
end