function C = configobj( varargin )
%CONFIGOBJ configobj constructor
%
%  c=CONFIGOBJ() default constructor
%
%  c=CONFIGOBJ(c) copy constructor
%
%  c=CONFIGOBJ(struct) create configobj from structure.
%
%  c=CONFIGOBJ(filename) read configobj from file.
%
%  A configobj can be used to create configuration files in a format
%  similar to the windows ini-files. In contrast to ini-files a configobj
%  supports infinitely nested sections and can store and retrieve some
%  (simple) matlab constructs like cells and matrices. Multiple comments
%  and one inline comment can be associated with a section or a
%  variable.
%
%  Example
%    An example configuration file:
%      
%      A = 1
%      #comment for B
%      B = {'test'}
%
%       #comment for section LEVEL1
%       [LEVEL1]  #inline comment for LEVEL1
%       C = [1 2 3]
%
%        [[LEVEL2]]  #nested section
%        D = {'one', 'two', 'three'}  #cell array of strings
%


%  Copyright 2005-2008 Fabian Kloosterman


if nargin==0
  %default constructor
  C = struct( 'section_comments', {{}}, 'section_inline_comments', {{}}, 'comments', struct(), 'inline_comments', struct(), 'keys', ...
              struct(), 'subsections', struct() );
  C = class( C, 'configobj' );
  
elseif nargin==1 && isa( varargin{1}, 'configobj' )
  %copy constructor
  C = class( struct( varargin{1} ), 'configobj' );
  
elseif nargin==1 && isa( varargin{1}, 'struct' )
  %create configobj from matlab structure
  C = struct( 'section_comments', {{}}, 'section_inline_comments', {{}}, 'comments', struct(), 'inline_comments', struct(), 'keys', ...
              struct(), 'subsections', struct() );
  
  fn = fieldnames( varargin{1} );
  n = numel(fn);

  for k=1:n
    
    if isempty(varargin{1})
      C.keys.(fn{k}) = {};
      C.comments.(fn{k}) = {};
      C.inline_comments.(fn{k})='';        
    elseif isstruct( varargin{1}.(fn{k}) )
        if numel(varargin{1}.(fn{k}))>1
            for ee = 1:numel(varargin{1}.(fn{k}))
                C.subsections.([fn{k} '_' num2str(ee)]) = configobj( varargin{1}.(fn{k})(ee) );
            end
        else
            C.subsections.(fn{k}) = configobj( varargin{1}.(fn{k}) );
        end
    else
      C.keys.(fn{k}) = varargin{1}.(fn{k});
      C.comments.(fn{k}) = {};
      C.inline_comments.(fn{k})='';
    end
    
  end
  
  C = class( C, 'configobj' );
  
elseif nargin==1 && ischar( varargin{1} )
  %read file
  C = readconfig( varargin{1} );
  
else
  
  error('ConfigObj:configobj:invalidArguments', ['Invalid signature for ' ...
                      'configobj constructor'])
  
end
