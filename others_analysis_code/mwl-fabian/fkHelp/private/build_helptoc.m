function document = build_helptoc( rootdir, doc_path, toolbox_name, T, cat_list )
%BUILD_HELPTOC

T(end+1) = struct('label', 'Functions -- alphabetical list', ...
                  'target', 'reference.html', ...
                  'icon', 'reficon.gif', ...
                  'level', 0 );

if cat_list
  T(end+1) = struct( 'label', 'Functions -- categorical list', ...
                     'target', 'reference1.html', ...
                     'icon', 'reficon.gif', ...
                     'level', 0 );
end

if numel(T)<1
  document = [];
  return
end

document = com.mathworks.xml.XMLUtils.createDocument('toc');

root = document.getDocumentElement;
setAttribute(root, 'version', '1.0');

top_item = createElement( document, 'tocitem' );
setAttribute(top_item, 'target', [toolbox_name '_product_page.html']);
setAttribute(top_item, 'image', '$toolbox/matlab/icons/book_mat.gif');
setTextContent(top_item, [toolbox_name 'Toolbox']);

add_toc_items( document, top_item, T );

appendChild( root, top_item );

xmlwrite(fullfile( rootdir, doc_path, 'helptoc.xml'), document);


function t = add_toc_items( document, parent, T )

element = [];
t = 1;
current_level = T(t).level;
while t<=numel(T)
  if T(t).level == current_level
    
    element = createElement( document, 'tocitem' );
    setTextContent( element, T(t).label );

    if ~isempty(T(t).target)
      setAttribute(element, 'target', T(t).target);
    end

    if ~isempty(T(t).icon)
      setAttribute(element, 'image', ['$toolbox/matlab/icons/' ...
                          T(t).icon]);
    end
    appendChild( parent, element );
    
  elseif T(t).level>current_level
    
    if isempty(element) || T(t).level>(current_level+1)
      error('fkHelp:build_helptoc:invalidToc', 'Invalid toc definition')
    end
    t = t - 1 + add_toc_items( document, element, T(t:end) );
    
  else

    t = t - 1;
    break
  
  end

  t = t + 1;
  
end
    