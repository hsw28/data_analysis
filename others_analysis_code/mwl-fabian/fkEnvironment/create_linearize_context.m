function ctx = create_linearize_context( ctxtype, varargin )
%CREATE_LINEARIZE_CONTEXT create linearization functions
%
%  c=CREATE_LINEARIZE_CONTEXT(type,...) where type is one of
%  'polyline', 'spline', 'circle' or 'track'. This function will
%  return a linearization context of the specified type and is
%  basically a front-end to the create_linearize_fcn_* functions.
%

%  Copyright 2008-2008 Fabian Kloosterman

%check arguments
if nargin<1
    help(mfilename)
    return
end

valid_types = {'polyline', 'spline', 'circle', 'track'};

if ~ischar(ctxtype) || ~any(strcmp(ctxtype, valid_types ) )
    error('create_linearize_context:invalidArgument', 'Invalid context type');
end

fcn = str2func( ['create_linearize_fcn_' ctxtype] );

ctx = fcn( varargin{:} );