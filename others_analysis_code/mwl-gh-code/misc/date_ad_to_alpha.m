function alphabetized_datestring = date_ad_to_alpha(old_datestring)

month = old_datestring(1:2);
day   = old_datestring(3:4);
year  = old_datestring(5:6);

lfun_assert_valid_date(month,day,year);

alphabetized_datestring = [year,month,day];

end

function lfun_assert_valid_date(month,day,year)

assert( length(day) == 2 );
assert( length(month) == 2);
assert( length(year) == 2);

n = @str2num;

assert( (n(day) >= 1) &&  (n(day) <= 31) );
assert(n(month) >= 1 && n(month) <= 12);
assert(n(year) >= 0 && n(year) <= 99);

end