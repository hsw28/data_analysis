function seg = seg_xor(varargin)
%SEG_XOR logical EXCLUSIVE OR on segment list
%
%  seg=SEG_XOR(seg1,seg2,...) performs an exclusive OR on the lists of
%  segments.
%

%  Copyright 2005-2008 Fabian Kloosterman

seg = seg_and( seg_or( varargin{:} ), seg_not( seg_and( varargin{:} ) ) );