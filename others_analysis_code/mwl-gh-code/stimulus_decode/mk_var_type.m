function var_type = mk_var_type(varargin)
% var_name: identifier (xpos, ypos, head direction, etc)
%
% var_category: CONTINUOUS   (linear tracks)
%                           CATEGORICAL (inbound OR outbound)
%                           CIRCULAR         (circular tracks, head direction)
%                           CONTINUOUS_FORKED (mazes with choice points)
%
%  var_units:  of measurement (eg MILIMETERS, PIXELS, RADIANS,
%                                                      METERS_PER_SECOND)
%
%  var_links: other vars considered along with this one for
%                     smoothing (eg, xpos and ypos are linked)

var_type.var_name = 'unset';
var_type.var_category = 'UNSET';
var_type.var_units = 'UNSET';
var_type.var_links = cell(0);

% properties for continuous variables

% properties for categorical variables

% properties for circular variables
% circular join -  all input points will get mapped into this range,
% and smoothing happens across this point
var_type.circular_join = [];

% properties for continuous_forked variables 
var_type.forked_paths = cell(0,1);
var_type.forked_links_m_no_n = cell(0,0);
var_type.forked_links_n_to_m  = cell(0,0);