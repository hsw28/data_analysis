function s = help_template(varargin)

%parse argument list
valid_args = {'body', 'title', 'label', 'prev_label', 'prev_target', 'next_label', ...
              'next_target', 'up_label', 'up_target' };

args = cell2struct( repmat({''}, numel(valid_args),1), valid_args );

if mod( numel(varargin), 2 ) == 1
  error('fkHelp:help_template:invalidArguments', ['Invalid number of ' ...
                      'arguments'])
end

for k=1:2:numel(varargin)
  
  if ~ischar( varargin{k} ) || ~ismember( varargin{k}, valid_args )
    error('fkHelp:help_template:invalidArguments', 'Invalid parameter')
  end
  
  if ~ischar( varargin{k+1} ) && ~iscellstr( varargin{k+1})
    error('fkHelp:help_template:invalidArguments', 'Invalid value')
  end

  args.(varargin{k}) = varargin{k+1};
  
end

%create output

s = ['<html><head><title>' args.title '</title></head><body>'];

s = [s '<table bgcolor="#e7ebf7" border=0 width="100%" cellpadding=0 cellspacing=0><tr><td>' args.label '</td><td align="right">'];

if ~isempty(args.prev_target)
  s = [s '<a href="' args.prev_target '"><img src="prev.gif" alt="Previous page" border=0 align=bottom></a>'];
end
if ~isempty(args.up_target)
  s = [s '&nbsp;<a href="' args.up_target '"><img src="up.gif" alt="Parent page" border=0 align=bottom></a>'];  
end
if ~isempty(args.next_target)
  s = [s '&nbsp;<a href="' args.next_target '"><img src="next.gif" alt="Next page" border=0 align=bottom></a>'];
end
  
s = [s '</td></tr></table>'];

if iscellstr(args.body)
  s = [s horzcat( args.body{:} )];
else
  s = [s args.body];
end

s = [s '<table bgcolor="#e7ebf7" border=0 width="100%" cellpadding=0 cellspacing=0><tr valign=top>'];

if ~isempty(args.prev_target)
  s = [s '<td align=left width="33%"><a href="' args.prev_target '"><img src="prev.gif" alt="Previous page" border=0 align=bottom></a>&nbsp;&nbsp;' args.prev_label '</td>'];
else
  s = [s '<td align=left width="33%">&nbsp;</td>'];
end
if ~isempty(args.up_target)
  s = [s '<td align=center width="34%"><a href="' args.up_target '"><img src="up.gif" alt="Parent page" border=0 align=bottom></a>&nbsp;&nbsp;' args.up_label '</td>'];
else
  s = [s '<td align=center width="34%">&nbsp;</td>'];
end
if ~isempty(args.next_target)
  s = [s '<td align=right>' args.next_label '&nbsp;&nbsp;<a href="' args.next_target '"><img src="next.gif" alt="Next page" border=0 align=bottom></a></td>'];
else
  s = [s '<td align=right width="33%">&nbsp;</td>'];
end

s = [s '</tr></table></body></html>'];
