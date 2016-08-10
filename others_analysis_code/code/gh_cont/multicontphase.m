function cdat_phase = multicontphase(cdat,varargin)

nchans = size(cdat.data,2);

cdat_phase = cdat; % copy over the names of chans, sizes of fields

for i = 1:nchans
    tmp_cdat = contchans(cdat,'chans',i);
    tmp_phase{i} = contphase(tmp_cdat,'method','hilbert');
    cdat_phase.data(:,i) = tmp_phase{i}.data;
    cdat_phase.datarange(i,:) = [-pi, pi];
end

%cdat_phase = tmp_phase{1};

%for i = 2:nchans
%    cdat_phase = contcombine(cdat_phase,tmp_phase{i});
%end

return