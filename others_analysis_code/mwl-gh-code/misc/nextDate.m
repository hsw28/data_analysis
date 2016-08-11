function newDateString = nextDate(oldDateString)
y = str2double(oldDateString(5:6));
m = str2double(oldDateString(1:2));
d = str2double(oldDateString(3:4));

if (d == 31)
    d = 1;
    m = m + 1;
    
    if (m == 13)
        m = 1;
        y = y + 1;
    end

else
    d = d + 1;
end

newDateString = [myNumToStr(m), myNumToStr(d), myNumToStr(y)];

end

function s = myNumToStr(n)
s1 = num2str(n);
if(numel(s1) > 2)
    error('myNumToStr:bad_number','Number is too high');
end
if(numel(s1) == 1)
    s = ['0', s1];
else
    s = s1;
end
end