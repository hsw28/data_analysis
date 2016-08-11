function lengths = stick_problem(n_tries)

first_length = ones(n_tries,1);
first_breakpoint = rand(size(first_length));
second_length = [first_breakpoint, 1-first_breakpoint];
second_length = max(second_length,[],2);

second_breakpoint = rand(size(first_length)) .* second_length;
third_length = [second_breakpoint, second_length - second_breakpoint];
third_length = max(third_length,[],2);

hist(third_length,400);
mean(third_length)