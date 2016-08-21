function seg = process_eeg_clip( timestamp, data, expansion )
%PROCESS_EEG_CLIP find out of range values in eeg data
%
%  PROCESS_EEG_CLIP(time,data,expansion) returns all time segments when
%  the eeg data has been clipped (i.e. abs( data ) >= 2047). The
%  expansion argument specifies how many samples on either side of
%  clipped values will be included as well (default=5).
%



if nargin<2
    expansion = 5;
end

% find clipped samples +/- 5 and remove them for ica

seg = {};

for l=1:size(data,2)

    d = diff( abs(data(:,l)) >= 2047 );
    seg{l} = event2seg( find( d==1 ) + 1, find( d==-1 ) );
    if ~isempty(seg{l})
        seg{l} = [ seg{l}(:,1)-expansion seg{l}(:,2)+expansion ];
        seg{l} = seg_or(seg{l});
        seg{l}( seg{l}<1 ) = 1;
        seg{l}( seg{l}>size(data,1) ) = size(data,1) ;
    end

end


for l=1:numel(seg)
    seg{l}(:,1) = timestamp( seg{l}(:,1) );
    seg{l}(:,2) = timestamp( seg{l}(:,2) );
end
