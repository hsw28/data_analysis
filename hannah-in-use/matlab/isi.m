function varargout = isi(event1, varargin)
%ISI return intervals for every event
%
%  Syntax
%
%      [i, idx] = isi( A, type)
%      [i, idx] = isi( A, B, type)
%
%  Description
%
%    [i, idx] = isi( A, type) This function will return the pre or post
%    event interval for every event in A. Which interval is returned is
%    determined by the type parameter, which can be one of 'pre', 'post',
%    'smallest', 'largest' (default = 'post'). The output vector i contains
%    the intervals for all events or NaN for events with unknown intervals.
%    Pre-event intervals are always negative, pos-event intervals are
%    always positive. The output vector idx contains for each event in A
%    the index of the event that was used to determine the interval.
%
%    [i, idx] = isi( A, B, type) In this case, event vector B is used as
%    reference and so for every event in A the cross-interval in B is
%    returned in i. The output vector idx now contains for each event in A
%    the index of the event in B that was used to determine the interval.
%
%  Example
%
%      e1 = cumsum( rand(100,1) );
%      e2 = cumsum( rand(150,1) );
%      i = isi( e1, e2, 'smallest');
%
%  See also CSI, INTERVALPRUNE
%

% Copyright 2005-2005 Fabian Kloosterman

if nargin<1
    help(mfilename)
    return
end

% set default interval type
returntype = 'post';

% check event vector
if ~isnumeric(event1)
    error('Invalid event times array.')
end

n = length(event1);

if n==0
    error('Empty event array')
end

% check interval type
if (nargin>1) && ischar(varargin{end})
    returntype = varargin{end};
end

% check if second event vector is present
event2 = [];

if (nargin>1) && isnumeric(varargin{1})
    event2 = varargin{1};
    m = length(event2);
    if m==0
        error('Empty event array')
    end
end


% compute intervals

if isempty(event2)
    
    % auto isi
    i_pre = [NaN ; -diff(event1(:))];
    ind_pre = [NaN 1:n-1]';
    i_post = [diff(event1(:)) ; NaN];
    ind_post = [2:n NaN]';

else 
    % cross isi
    ind_pre = floor( interp1(event2, 1:m, event1, 'linear') )';
    valids = find(~isnan(ind_pre));
    i_pre = NaN(n, 1);
    if ~isempty(valids)
        i_pre(valids) = event2(ind_pre(valids)) - event1(valids);
        i_pre((max(valids)+1):end) = event2(end) - event1((max(valids)+1):end);
        ind_pre((max(valids)+1):end) = m;
    end

    ind_post = ceil( interp1(event2, 1:m, event1, 'linear') )';
    valids = find(~isnan(ind_post));
    i_post = NaN(n, 1);
    if ~isempty(valids)
        i_post(valids) = event2(ind_post(valids)) - event1(valids);
        i_post(1:(min(valids)-1)) = event2(1) - event1(1:(min(valids)-1));
        ind_post(1:(min(valids)-1)) = 1;
    end

end

% assign outputs
if nargout>=1
    switch returntype
        case 'pre'
            varargout{1} = i_pre;
        case 'post'
            varargout{1} = i_post;
        case 'smallest'
            varargout{1} = i_pre;
            m_ind = find( abs(i_post)<=abs(i_pre) );
            varargout{1}(m_ind) = i_post(m_ind);
            varargout{1}( isnan(i_pre) | isnan(i_post) ) = NaN;
        case 'largest'
            varargout{1} = i_pre;
            m_ind = find( abs(i_post)>abs(i_pre) );
            varargout{1}(m_ind) = i_post(m_ind);           
            varargout{1}( isnan(i_pre) | isnan(i_post) ) = NaN;
        otherwise
            error('invalid return type')
    end
end
if nargout>=2
    switch returntype
        case 'pre'
            varargout{2} = ind_pre;
        case 'post'
            varargout{2} = ind_post;
        case 'smallest'
            varargout{2} = ind_pre;
            m_ind = find( abs(i_post)<=abs(i_pre) );
            varargout{2}(m_ind) = ind_post(m_ind);
            varargout{2}( isnan(i_pre) | isnan(i_post) ) = NaN;
        case 'largest'
            varargout{2} = ind_pre;
            m_ind = find( abs(i_post)>abs(i_pre) );
            varargout{2}(m_ind) = ind_post(m_ind);           
            varargout{2}( isnan(i_pre) | isnan(i_post) ) = NaN;
        otherwise
            error('invalid return type')
    end
end
