function cdat_env = multicontenv(cdat,varargin)

nchans = size(cdat.data,2);

% copy over chanlabels, etc
cdat_env = cdat;

for i = 1:nchans
    tmp_cdat = contchans(cdat,'chans',i);
    tmp_env = contenv(tmp_cdat);
    cdat_env.data(:,i) = tmp_env.data;
    cdat_env.datarange(i,:) = [min(tmp_env.data),max(tmp_env.data)];
end

%cdat_env = tmp_env{1};

%for i = 2:nchans
%    cdat_env = contcombine(cdat_env,tmp_env{i});
%end

return