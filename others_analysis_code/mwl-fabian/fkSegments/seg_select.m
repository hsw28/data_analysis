function varargout = seg_select(segments, time, data, option)
%SEG_SELECT select all data within segments
%
%  s=SEG_SELECT(segments,x) returns a cell array with for each segment
%  the values in the column vector x that are within that segment.
%
%  s=SEG_SELECT(segments,xx) where xx is a cell array of column vectors,
%  returns a cell matrix with for each segment and each vector in xx the
%  values in the vector that are within the segment.
%
%  [s,i]=SEG_SELECT(...) also returns a cell matrix of indices.
%
%  [s,i,y]=SEG_SELECT(segment,x,data) where data is a matrix or a cell
%  array of matrices corresponding to the vectors in x. Returns for each
%  segment and for each vector in x also the selected data.
%
%  [...,n]=SEG_SELECT(...) returns for each segment the number of
%  elements of the vectors x it contains.
%
%  [...]=SEG_SELECT(...,'all') returns a concatenated array of all
%  elements in the vectors x that are contained in any of the segments.
%

%  Copyright 2005-2008 Fabian Kloosterman

if (nargin<2)
    help(mfilename)
    return
end

if (size(segments,2) ~= 2) || (size(segments,1)<1 || ~isnumeric(segments))
    error('seg_select:invalidSegments', 'First argument is an invalid or empty list of segments')
end

if isnumeric(time)
    time = {time};
elseif ~iscell(time)
    error('seg_select:invalidArguments', 'Second argument is invalid')
end

%option = '';

if nargin<3 || isempty(data)
  data = {};
elseif ischar(data)
  option = data;
  data = {};
elseif isnumeric(data)
  data = {data};
elseif ~iscell(data)
    error('seg_select:invalidArguments', 'Invalid data')
end

if ~exist('option','var') || isempty(option)
    option = 'apart';
end

if nargout>4
    error('seg_select:invalidArguments', 'Too many output arguments')
end

selindex = cell( size(segments,1), numel(time) );
seltime = cell( size(segments,1), numel(time) );
seldata = cell( size(segments,1), numel(time) );
selnum = zeros( size(segments,1), numel(time) );

if strcmp(option, 'all')
    option = 1;  %concatenate all segments
else
    option = 0;
end


%for each cell in time array

for k = 1:numel(time)

    if numel(time{k})==0
        continue;
    end
    
    %loop through all segments
    for s = 1:size(segments, 1)
        
        i = find( time{k} >= segments(s,1) & time{k} <= segments(s,2));
        selindex{s,k} = i;
        
        if option==0 %no concatenation
            seltime{s,k} = time{k}(i,:);
        
            if ~isempty(data)
                seldata{s, k} = data{k}(i,:);
            end
        end
             
        selnum(s,k) = length(i);
        
    end
    
end


if option %concatenate
    
    for k = 1:numel(time)
    
        idx{k} = vertcat(selindex{:, k}); %#ok
        idx{k} = unique(idx{k});
        varargout{1}{k} = time{k}(idx{k},:);
        
        seldata = {};
        if ~isempty(data)
            seldata{k} = data{k}(idx{k},:);
        else
            seldata{k} = [];
        end
        
    end
    
    selindex = idx;
    
else
    
    varargout{1} = seltime;
    
end


if nargout>1
    varargout{2} = selindex;
end
if nargout>2
    varargout{3} = seldata;
end
if nargout>3
    varargout{4} = selnum;
end
