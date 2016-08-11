function i = orderOfBursts(b,arity)

bursts = getBurstsOfArity(b,arity);
bursts = reshape(bursts,[],1);
IRIs = diff( cell2mat(bursts) ,1,2 );

[~,i] = sort( IRIs(:,1) );