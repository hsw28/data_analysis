% fkUtilities Toolbox
% Version 0.4.1 26-Sep-2009
%
% GUIs and graphics
%   axismatrix         - create a matrix of axes
%   plot_bars          - create bar plot
%
% Geometry
%   dist_point_segment - calculate distance between points and a line segment
%   inclPoints         - select 2D coordinates based on inclusive and exclusive regions
%   inrect             - check whether points x,y are within a rectangle
%   dist2point         - calculate distance to point
%   inellipse          - find points in ellipse
%
% Working with structures and cells
%   struct2tree        - show matlab structure or path as tree
%   applyfcn           - apply function to cell array or all fields of structure
%   struct_intersect   - returns fields in S1 that are present in S2
%   struct_setdiff     - returns fields in structure S1 that are not present in S2
%   struct_union       - return the union of two structures
%   apply2cell         - apply function element-wise to cell arrays
%   apply2struct       - apply function to fields in structs
%   cell2str           - convert cell to string representation
%   explorestruct      - visually explore struct
%   struct2str         - convert struct to string representation
%   selectfields       - select fields from structure
%
% Files and directories
%   fullpath           - get full path for a given relative path
%   delvarmat          - Delete variable(s) from MAT-file
%   dirfun             - apply function to directories recursively
%   filefun            - apply function to files recursivley
%
% Randomize
%   randdist           - will compute the randomization distribution
%   localshuffle       - local shuffle vector
%   randcycle          - randomly cycles columns or rwos
%   randomize          - randomize a matrix
%   randswap           - randomly swap elements of a matrix
%   shake              - Randomize a matrix along a specific dimension
%
% Vectors and matrices
%   zerocrossing       - find zero crossings in signal
%   nearestpoint       - find the nearest value in y for x
%   inrange            - test whether numbers are within range
%   ismonotonic        - returns a boolean value indicating whether or not a vector is monotonic
%   smoothn            - smooth data with a gaussian kernel
%   interlace          - Insert Subarrays into Array
%   ceilto             - round towards Inf
%   floorto            - round towards -Inf
%   roundto            - round numbers
%   uncat              - Unconcatenate Array
%   normalize             - normalizes an array
%   matrixfun             - perform function on matrix for 1 or more dimensions
%
% Function generators
%   alpha_gen             - alpha function generator
%   exp_gen               - exponential function generator
%   normal_gen            - normal function generator
%   binfcn_gen            - generator of binning functions
%
% Stats and distributions
%   gaussn                - create gaussian kernel
%   choose                - return all possible combinations
%   unifrnd_seg           - uniformly sampled random numbers from a set of segments
%
% Misc
%   parseArgs             - Helper function for parsing varargin. 
%   struct2param          - convert structure to parameter/value pairs
%   makesources           - MAKESOURCES
%   batch_process         - call function multiple times with different input arguments
%   bresenham             - bresenham's algorithm for line digitization
%   create_openfield_path - create a random path
%   fcorrcoef             - correlation coefficient of two functions
%   nanquad               - evaluate integral, ignoring NaNs
%   swap                  - swap inputs
%   debugmsg              - write message to screen or file
%   multicolor            - create custom colormap
%   onoff                 - on/off utility
%   plural                - make plural
%   process_callbacks     - process callback functions
%   rgb2hex               - convert rgb colors to hexadecimal
%   sortedhist            - histogram of sorted variable X
%   super                 - super object of object
%   tostr                 - convert to string
%   verbosemsg            - write message to screen or file
%   loaddir               - executes a load command for directory
%   makequote             - convert string into quote
%   mmrepeat              - Repeat or count repeated values in a vector.
%   point2polyline        - find nearest point on polyline for a set of points
%   localmaximum          - find local maxima
%   fill_dvd              - create dvd file lists for data backup
%   binpack               - efficient packing of elements in container
%   padvector             - pad a vector
%   loadconfig            - load configuration
%   ndmedian              - compute N-dimensional median
%   saveconfig            - save configuration
%   setconfigpath         - set configuration path in preferences
%   uiloaddir             - user interface for loaddir function
%   binsearch             - binary vector search
%   flattencurve          - flattening of 2D curve
%   thickencurve          - create curve outline
%   get_verbose_msg_level - GET_VERBOSE_LEVEL helper function to get verbose level
%   localmaximum2d        - find local maxima in matrix
%   new_diagnostics_log   - create standard diagnostics log
