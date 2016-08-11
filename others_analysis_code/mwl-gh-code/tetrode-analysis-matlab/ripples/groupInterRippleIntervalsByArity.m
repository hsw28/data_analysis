function IRIs = groupInterRippleIntervalsByArity(bursts)
%

IRIs = cmap(@(a) process(a), bursts);

end



function IRIs = process(a)

% Handle arity 1 and arities w/ no bursts
if(isempty(a) || numel(a{1}) == 1)
    IRIs = [];
    return
end

% Otherwise (at least one burst)

% Assuming burst times are in row vectors
% get an array w/ bursts in rows, ripples in columns
bursts = cell2mat( reshape(a,[],1) );

IRIs = diff(bursts,1,2);
%IRIs = bsxfun(@minus, bursts, bursts(:,1));
%IRIs = IRIs(:,2:end);
IRIs = reshape(IRIs, 1,[]);

end