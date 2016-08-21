function open_pool()

if matlabpool('size')<1
    matlabpool('open');
else
    sprintf('Matlab pool is already open with size:%d\n', matlabpool('size'));
end

end