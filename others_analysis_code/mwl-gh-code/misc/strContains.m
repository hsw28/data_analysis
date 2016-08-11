function b = strContains(s,target)

    b = ~isempty(regexp(s,target,'ONCE'));

end