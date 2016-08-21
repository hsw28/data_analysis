function data = eeg_deartefact( data, A, W, artefacts)

if nargin<1
    help(mfilename)
    return
end

if nargin<2
    return
end

if nargin<4
    error('Need four inputs')
end

if isempty(A) || isempty(W)
    return
end

A(:,artefacts) = 0;
data = (A*W*data')';