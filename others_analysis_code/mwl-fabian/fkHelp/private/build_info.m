function build_info( toolbox_path, doc_path, toolbox_name )
%BUILD_INFO
%


document = com.mathworks.xml.XMLUtils.createDocument('productinfo');
root = document.getDocumentElement;

setAttribute( root, 'xmlns:xsi', 'http://www.w3.org/2001/XMLSchema-instance' );
setAttribute( root, 'xsi:noNamespaceSchemaLocation', 'http://www.mathworks.com/namespace/info/v1/info.xsd');

element = createProcessingInstruction( document, 'xml-stylesheet', 'type="text/xsl" href="http://www.mathworks.com/namespace/info/v1/info.xsl"' );
appendChild(root, element);

element = createElement( document, 'matlabrelease' );
setTextContent(element, '14');
appendChild(root, element);

element = createElement( document, 'name' );
setTextContent(element, toolbox_name);
appendChild(root, element);

element = createElement( document, 'type' );
setTextContent(element, 'toolbox');
appendChild(root, element);

element = createElement( document, 'icon' );
setTextContent(element, '$toolbox/matlab/icons/matlabicon.gif');
appendChild(root, element);

element = createElement( document, 'help_location' );
setTextContent(element, doc_path);
appendChild(root, element);

element = createElement( document, 'list' );

listitem = createElement( document, 'listitem');
addchild( listitem, 'label', 'Help', 'callback', ['helpwin ' toolbox_name], ...
          'icon', '$toolbox/matlab/icons/book_mat.gif' );
appendChild(element, listitem);

if exist( fullfile( toolbox_path, 'demos.xml' ), 'file' )
  listitem = createElement( document, 'listitem');
  addchild( listitem, 'label', 'Demos', 'callback', ['demo toolbox ' toolbox_name ''], ...
            'icon', '$toolbox/matlab/icons/demoicon.gif' );
  appendChild(element, listitem);
end

%add other entries
if exist(fullfile(toolbox_path, doc_path, 'start.txt' ), 'file' )
  
  T = parse_toc( fullfile(toolbox_path, doc_path, 'start.txt' ), false );
  
  for k=1:numel(T)
    
    listitem = createElement( document, 'listitem');
    addchild( listitem, 'label', T(k).label, 'callback', T(k).target, ...
              'icon', ['$toolbox/matlab/icons/' T(k).icon] );
    appendChild(element, listitem);    
    
  end
  
end


appendChild(root, element);

xmlwrite(fullfile( toolbox_path, 'info.xml'), document);


  function addchild(parent, varargin)
 
  for k=1:2:numel(varargin)

    E = createElement( document, varargin{k} );
    setTextContent( E, varargin{k+1} );
    appendChild( parent, E );
    
  end
  
  end

end
