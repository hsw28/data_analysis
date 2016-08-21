function close_pool()

if matlabpool('size')>0
    matlabpool('close');
else
    sprintf('Matlab pool is already closed!\n');
end

end