function s = waitbar_text(val, s)
    
try
    if nargin==1
        s = [];
    end
    
    if isempty(s)
        s.range = [0 1];
        s.value = 0;
        s.width = 50;
        s.min_dValue = range(s.range) / s.width;
        s.iter_count = 0;
        s.d_iter = 0;
        s.first_draw = 1;
    end
    
    s.iter_count = s.iter_count + 1;
    s.d_iter = val / s.iter_count;
    
    if val > s.range(2) - (s.d_iter * 1.1)
    
        s.value = s.range(2);
        draw_wait_bar(s);
        fprintf(' DONE!\n');
    
    elseif val - s.value >= s.min_dValue
        s.value = val;
        draw_wait_bar(s);
        s.first_draw = 0;
    
    end    

catch event
    fprintf('\n');
    rethrow(event)
end
    
end

function draw_wait_bar(s)

    if s.first_draw == 0
        eraseStr = repmat(sprintf('\b'), s.width+2, 1);
        fprintf(eraseStr);
    end
    
    nDone = ceil( (s.value - s.range(1)) / s.min_dValue);
    nRem = s.width - nDone - 1;

    doneStr = repmat('=', nDone, 1);
    
    if nDone ~= s.width
        curPosStr = '>';
        remStr = repmat(' ', nRem, 1);
    else
        curPosStr = '';
        remStr = '';
    end


    str = sprintf('[%s%s%s]', doneStr, curPosStr, remStr);
    fprintf(str);
end

