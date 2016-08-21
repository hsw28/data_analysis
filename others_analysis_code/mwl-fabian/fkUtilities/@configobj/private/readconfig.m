function C = readconfig( filename )
%READCONFIG read configuration object
%
%  c=READCONFIG(filename) this function will parse the contents of the
%  given configuration file and return a valid configobj or an error if
%  the file is not a valid configuration file.
%


%  Copyright 2005-2008 Fabian Kloosterman


%regular expression to identify sections, comments and keys
re_section = '\s*(?<level_start>[\[]+)(?<name>[a-zA-Z]\w*)(?<level_end>[\]]+)\s*(?<comment>#.*)?';
re_comment = '^\s*#(?<comment>.*)';
re_key = '\s*(?<key>[a-zA-Z]\w*)\s*=\s*(?<value>[^#]+)(?<comment>#.*)?';

%check input arguments
if nargin<1 || ~ischar(filename)
  error('ConfigObj:readconfig:invalidFile', 'Invalid file name')
end

%open file for reading
fid = fopen( filename, 'r' );

if fid<0
  error('ConfigObj:readconfig:invalidFile', 'Can''t open file')
end

%common variables for recursively called fill_section function
section = 0;
line_number = 0;
names = {};
comments = {};

%create empty configobj
C = configobj();

%parse file
C = fill_section(C);


  function cobj = fill_section(cobj)
  %FILL_SECTION
  
  while 1
    %get line
    L = fgetl( fid );
    line_number = line_number + 1;
  
    if isnumeric(L) && L==-1 %end of file
      names = {};
      break
    end
  
    %trim whitespace
    L = strtrim( L );

    if isempty(L)
      continue;
    end
    
    %does this line contain a key/value pair?
    names = regexp(L, re_key, 'names' );
    
    if ~isempty(names)
      
      %try to evaluate value, if fails the value is a text string
      try
        val = eval( names.value );
      catch
        val = names.value;
      end
      
      %store key/value pair in configobj
      cobj = subsasgn(cobj, struct('type', '.', 'subs', names.key), val);
      
      %store inline comment
      if ~isempty(names.comment)
        cobj = setcomment(cobj, names.key, names.comment(2:end), ...
                                'inline');
      end
      
      %store comments
      if ~isempty(comments)
        cobj = setcomment(cobj, names.key, comments);
        comments = {};
      end
      continue
    end  
  
    
    %does this line contain a new section?
    names = regexp(L, re_section, 'names');
  
    if ~isempty(names)
      %determine level of section ( based on number of [ )
      mylevel = section;
      level = numel(names.level_start);
      if level~=numel(names.level_end) || level>(section+1)
        error('ConfigObj:readconfig:ParseError', ['Invalid section definition: ' ...
                            'line ' num2str(line_number)]);
      end
      
      section = level;
      if level>mylevel
        %parse all subsections
        while section==(mylevel+1)
          myname = names.name;
          
          %create new configobj for subsection
          val = configobj();
          
          %store inline comment
          if ~isempty(names.comment)
            val = setcomment( val, names.comment(2:end), 'inline');
          end
          
          %store comments
          if ~isempty(comments)
            val = setcomment( val, comments);
            comments = {};
          end
          
          %parse subsection
          val = fill_section( val );
          
          %assign it to section configobj
          cobj = subsasgn(cobj, struct('type', '.', 'subs', myname), ...
                          val);
          
          if isempty(names)
            return %section complete
          end          
          
        end
        
      end
      
      return %section complete
      
    end    
    
    %does this line contain only a comment
    names = regexp(L, re_comment, 'names');
    
    if ~isempty(names)
      %collect comments
      comments{end+1} = names.comment;
      continue;
    end

    error('ConfigObj:readconfig:ParseError', ['Parsing error in file ' ...
                        filename ' on line: ' num2str(line_number)]);
    
  end

  end

end