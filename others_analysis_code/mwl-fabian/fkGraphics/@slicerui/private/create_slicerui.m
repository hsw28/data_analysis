function ui = create_slicerui( grid, state, hash )

import javax.swing.*
import java.awt.*

c = GridBagConstraints();
c.fill = GridBagConstraints.HORIZONTAL;
c.weightx = 1; c.weighty= 1;

dim_names = names(grid);
%x_dim = find(strcmp( state.x, dim_names ));
%y_dim = find(strcmp( state.y, dim_names ));

%create main panel
ui.mainpanel = JPanel();
ui.mainpanel.setLayout(BoxLayout( ui.mainpanel, 3 ) );

%create panel for x,y dimension selection
ui.subpanel = JPanel( GridBagLayout() );
ui.mainpanel.add(ui.subpanel);

ui.subpanel.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 40));

%create X label
ui.xlabel = JLabel('X',SwingConstants.CENTER);
c.gridx=0; c.gridy=0;
c.gridwidth = 1;
ui.subpanel.add(ui.xlabel,c);

%create x dimension selector
ui.xcombo = JComboBox( dim_names );
ui.xcombo.setSelectedIndex( state.x-1 );
c.gridx=1; c.gridy=0;
c.gridwidth=1; c.weightx=2;
ui.subpanel.add(ui.xcombo,c);

%create Y label
ui.ylabel = JLabel('Y',SwingConstants.CENTER);
c.gridx=2; c.gridy=0;
c.gridwidth = 1; c.weightx = 1;
ui.subpanel.add(ui.ylabel,c);

%create y dimension selector
ui.ycombo = JComboBox( dim_names );
ui.ycombo.setSelectedIndex(state.y-1);
c.gridx=3;c.gridy=0;
c.gridwidth=1; c.weightx = 2;
ui.subpanel.add(ui.ycombo,c);

%create Z label
ui.zlabel = JLabel('Z',SwingConstants.CENTER);
c.gridx=4; c.gridy=0;
c.gridwidth = 1; c.weightx = 1;
ui.subpanel.add(ui.zlabel,c);

%create z dimension selector
ui.zcombo = JComboBox( vertcat( {'none'}, dim_names(:) ) );
ui.zcombo.setSelectedIndex(state.z);
c.gridx=5;c.gridy=0;
c.gridwidth=1; c.weightx = 2;
ui.subpanel.add(ui.zcombo,c);

%add callbacks
set( ui.xcombo, 'ActionPerformedCallback', {@xcombochanged, hash} );
set( ui.ycombo, 'ActionPerformedCallback', {@ycombochanged, hash} );  
set( ui.zcombo, 'ActionPerformedCallback', {@zcombochanged, hash} );  

ui.scrollpanel = JPanel();
ui.scrollpanel.setLayout( BoxLayout( ui.scrollpanel, 3 ) );

ui.mainpanel.add( JScrollPane( ui.scrollpanel ) );

for k=1:ndims(grid)

  %add panel for each dimension
  ui.dim(k).panel = JPanel( GridBagLayout() );

  
  row = 0;
  
  %add dimension name label
  ui.dim(k).label = JLabel(dim_names{k});
  c.gridx = 0; c.gridy = row;
  c.gridwidth = 6; c.weightx = 6;
  ui.dim(k).label.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 30));
  ui.dim(k).label.setForeground( java.awt.Color(0.6,0,0) );

  ui.dim(k).panel.add( ui.dim(k).label, c);

  row= row + 1;
  
  %add slice method radio buttons
  ui.dim(k).radio1 = JRadioButton('slice');
  ui.dim(k).radio2 = JRadioButton('sum');
  ui.dim(k).radio3 = JRadioButton('max');
  
  ui.dim(k).radio1.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 20));
  ui.dim(k).radio2.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 20));
  ui.dim(k).radio3.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 20));

  ui.dim(k).radio1.setFocusPainted(false);
  ui.dim(k).radio2.setFocusPainted(false);
  ui.dim(k).radio3.setFocusPainted(false);  
  
  ui.dim(k).radio1.setBorder(BorderFactory.createCompoundBorder( ...
                   BorderFactory.createLineBorder(Color.red), ...
                   ui.dim(k).radio1.getBorder()));  
  
  %add callbacks
  set( ui.dim(k).radio1, 'ActionPerformedCallback', {@slicemethodchanged, hash, k});
  set( ui.dim(k).radio2, 'ActionPerformedCallback', {@slicemethodchanged, hash, k});
  set( ui.dim(k).radio3, 'ActionPerformedCallback', {@slicemethodchanged, hash, k});    

  ui.btngroup = ButtonGroup();
  ui.btngroup.add(ui.dim(k).radio1);
  ui.btngroup.add(ui.dim(k).radio2);
  ui.btngroup.add(ui.dim(k).radio3);

  c.gridx = 0; c.gridy = row;
  c.gridwidth = 2; c.weightx = 1;
  ui.dim(k).panel.add(ui.dim(k).radio1,c);

  c.gridx = 2;
  ui.dim(k).panel.add(ui.dim(k).radio2,c);

  c.gridx = 4;
  ui.dim(k).panel.add(ui.dim(k).radio3,c);
  
  
  lbls = labels(grid,k);
  
  row = row + 1;
  
  %add slice scrollbar 1
  ui.dim(k).scrollbar = JScrollBar(SwingConstants.HORIZONTAL, ...
                                   state.slice_index(k), 1, 1, size(grid,k)+1) ;
  c.gridx = 0; c.gridy = row;
  c.gridwidth = 3; c.weightx = 1;
  ui.dim(k).scrollbar.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 20));
  set( ui.dim(k).scrollbar, 'AdjustmentValueChangedCallback', {@slicechanged, hash, k});
  
  ui.dim(k).panel.add(ui.dim(k).scrollbar, c);

  %add slice label
  ui.dim(k).slicelabel = JLabel( lbls{state.slice_index(k)}, SwingConstants.CENTER);
  c.gridx = 3;
  c.gridwidth = 3;
  ui.dim(k).slicelabel.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 20));  
  ui.dim(k).panel.add(ui.dim(k).slicelabel, c);  
  
  row = row + 1;
  
  %add slice scrollbar 2
  ui.dim(k).scrollbar2 = JScrollBar(SwingConstants.HORIZONTAL, ...
                                    state.slice_index2(k), 1, 1, size(grid,k)+1) ;
  c.gridx = 0; c.gridy = row;
  c.gridwidth = 3; c.weightx = 1;
  ui.dim(k).scrollbar2.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 20));  
  set( ui.dim(k).scrollbar2, 'AdjustmentValueChangedCallback', {@slice2changed, hash, k});
  
  ui.dim(k).panel.add(ui.dim(k).scrollbar2, c);
  
  %add slice label 2
  ui.dim(k).slicelabel2 = JLabel( lbls{state.slice_index2(k)}, SwingConstants.CENTER);
  c.gridx = 3;
  c.gridwidth = 3;
  ui.dim(k).slicelabel2.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 20));  
  ui.dim(k).panel.add(ui.dim(k).slicelabel2, c);  
  
  row = row + 1;  
  
  %add slice scrollbar 3
  ui.dim(k).scrollbar3 = JScrollBar(SwingConstants.HORIZONTAL, ...
                                    state.slice_index3(k), 1, 1, size(grid,k)+1) ;
  c.gridx = 0; c.gridy = row;
  c.gridwidth = 3; c.weightx = 1;
  ui.dim(k).scrollbar3.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 20));  
  set( ui.dim(k).scrollbar3, 'AdjustmentValueChangedCallback', {@slice3changed, hash, k});
  
  ui.dim(k).panel.add(ui.dim(k).scrollbar3, c);

  %add slice label 3
  ui.dim(k).slicelabel3 = JLabel( lbls{state.slice_index3(k)}, SwingConstants.CENTER);
  c.gridx = 3;
  c.gridwidth = 3;
  ui.dim(k).slicelabel3.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 20));  
  ui.dim(k).panel.add(ui.dim(k).slicelabel3, c);

  
  ui.scrollpanel.add(ui.dim(k).panel);
  ui.dim(k).panel.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 90));
  ui.dim(k).panel.setPreferredSize(java.awt.Dimension(200, 50));
  
  switch state.slice_method{k}
   case 'slice'
    ui.dim(k).radio1.setSelected(true);
    ui.dim(k).scrollbar.setEnabled(true);
    ui.dim(k).scrollbar2.setEnabled(true);    
    ui.dim(k).scrollbar3.setEnabled(true);        
   case 'mean'
    ui.dim(k).radio2.setSelected(true);
    ui.dim(k).scrollbar.setEnabled(false);
    ui.dim(k).scrollbar2.setEnabled(false);
    ui.dim(k).scrollbar3.setEnabled(false);
   case 'max'
    ui.dim(k).radio3.setSelected(true);
    ui.dim(k).scrollbar.setEnabled(false);
    ui.dim(k).scrollbar2.setEnabled(false);
    ui.dim(k).scrollbar3.setEnabled(false);
  end  
  
  if k==state.x || k==state.y
    ui.dim(k).panel.setVisible(false);
  end
  
  if k==state.z
    ui.dim(k).scrollbar2.setVisible(true);
    ui.dim(k).scrollbar3.setVisible(true);    
    ui.dim(k).slicelabel2.setVisible(true);
    ui.dim(k).slicelabel3.setVisible(true);
  else
    ui.dim(k).scrollbar2.setVisible(false);
    ui.dim(k).scrollbar3.setVisible(false); 
    ui.dim(k).slicelabel2.setVisible(false);
    ui.dim(k).slicelabel3.setVisible(false);
    %ui.dim(k).panel.setMaximumSize(java.awt.Dimension(java.lang.Short.MAX_VALUE, 70));
  end
  
end


function slicechanged(hObj, event, hash, idx)

h = mhashtable(hash);
A = h.get('slicer');

val = A.ui.dim(idx).scrollbar.getValue();

if val~=A.state.slice_index(idx)
  A.state.slice_index(idx) = val;
  lbls = labels(A.grid,idx);
  A.ui.dim(idx).slicelabel.setText(lbls{val});
  h.put('slicer', A);

  process_callbacks(A.callbacks, hObj, A.state);
end

function slice2changed(hObj, event, hash, idx)

h = mhashtable(hash);
A = h.get('slicer');

val = A.ui.dim(idx).scrollbar2.getValue();

if val~=A.state.slice_index2(idx)
  A.state.slice_index2(idx) = val;
  lbls = labels(A.grid,idx);
  A.ui.dim(idx).slicelabel2.setText(lbls{val});
  h.put('slicer', A);

  process_callbacks(A.callbacks, hObj, A.state);
end

function slice3changed(hObj, event, hash, idx)

h = mhashtable(hash);
A = h.get('slicer');

val = A.ui.dim(idx).scrollbar3.getValue();

if val~=A.state.slice_index3(idx)
  A.state.slice_index3(idx) = val;
  lbls = labels(A.grid,idx);
  A.ui.dim(idx).slicelabel3.setText(lbls{val});
  h.put('slicer', A);

  process_callbacks(A.callbacks, hObj, A.state);
end


function slicemethodchanged(hObj, event, hash, idx)

h = mhashtable(hash);
A = h.get('slicer');

label = get(hObj, 'Text');

if strcmp(label, A.state.slice_method{idx} )
  return
end

switch label
 case 'slice'
  awtinvoke(A.ui.dim(idx).scrollbar, 'setEnabled(Z)', true);
  awtinvoke(A.ui.dim(idx).scrollbar2, 'setEnabled(Z)', true);
  awtinvoke(A.ui.dim(idx).scrollbar3, 'setEnabled(Z)', true);  
 otherwise
  awtinvoke(A.ui.dim(idx).scrollbar, 'setEnabled(Z)', false);  
  awtinvoke(A.ui.dim(idx).scrollbar2, 'setEnabled(Z)', false);  
  awtinvoke(A.ui.dim(idx).scrollbar3, 'setEnabled(Z)', false);    
end
  
A.state.slice_method{idx} = label;
h.put('slicer',A);

process_callbacks(A.callbacks, hObj, A.state);


function xcombochanged(hObj, event, hash)

h = mhashtable(hash);
A = h.get('slicer');

xdim = A.ui.xcombo.getSelectedIndex();
ydim = A.ui.ycombo.getSelectedIndex();
zdim = A.ui.zcombo.getSelectedIndex();

if A.state.x == xdim+1
  return
end

A.state.x = xdim+1;

if xdim==(zdim-1)
  awtinvoke(A.ui.zcombo, 'setSelectedIndex', 0);
end

if A.comboboxchange
  A.comboboxchange = 0;
else
  if xdim==ydim
    A.comboboxchange = 1;
    h.put('slicer',A);
    %change the ydim
    ydim_idx = mod( ydim+1 , A.ui.ycombo.getItemCount());
    awtinvoke(A.ui.ycombo, 'setSelectedIndex', ( ydim_idx ));
  return
  end
end

h.put('slicer', A);

for k=1:numel(A.ui.dim)
  if k==(xdim+1) || k==(ydim+1)
    awtinvoke(A.ui.dim(k).panel, 'setVisible(Z)', false);
  else
    awtinvoke(A.ui.dim(k).panel, 'setVisible(Z)', true);
  end
end
A.ui.mainpanel.updateUI();
%fire update event
process_callbacks(A.callbacks, hObj, A.state);

function ycombochanged(hObj, event, hash)

h = mhashtable(hash);
A = h.get('slicer');

xdim = A.ui.xcombo.getSelectedIndex();
ydim = A.ui.ycombo.getSelectedIndex();
zdim = A.ui.zcombo.getSelectedIndex();

if A.state.y == ydim+1
  return
end

A.state.y = ydim + 1;

if ydim==(zdim-1)
  awtinvoke(A.ui.zcombo, 'setSelectedIndex', 0);
end

if A.comboboxchange
  A.comboboxchange = 0;
else
  if xdim==ydim
    A.comboboxchange = 1;
    h.put('slicer',A);
    %change the ydim
    xdim_idx = mod( xdim + 1 , A.ui.xcombo.getItemCount());
    awtinvoke(A.ui.xcombo, 'setSelectedIndex', ( xdim_idx ));
  return
  end
end

h.put('slicer', A);

for k=1:numel(A.ui.dim)
  if k==(xdim+1) || k==(ydim+1)
    awtinvoke(A.ui.dim(k).panel, 'setVisible(Z)', false);
  else
    awtinvoke(A.ui.dim(k).panel, 'setVisible(Z)', true);
  end
end
A.ui.mainpanel.updateUI();
%fire update event
process_callbacks(A.callbacks, hObj, A.state);


function zcombochanged(hObj, event, hash)

h = mhashtable(hash);
A = h.get('slicer');


if A.comboboxchange
  A.comboboxchange=0;
  h.put('slicer', A);
  return;
else

  xdim = A.ui.xcombo.getSelectedIndex();
  ydim = A.ui.ycombo.getSelectedIndex();
  zdim = A.ui.zcombo.getSelectedIndex();

  if A.state.z == zdim
    return
  end  
  
  if xdim==(zdim-1) || ydim==(zdim-1)
    %reverse
    A.comboboxchange=1;
    h.put('slicer', A);
    awtinvoke(A.ui.zcombo, 'setSelectedIndex', A.state.z);
    return
  else
    if zdim~=0
      awtinvoke(A.ui.dim(zdim).scrollbar2, 'setVisible(Z)', true);
      awtinvoke(A.ui.dim(zdim).scrollbar3, 'setVisible(Z)', true);    
      awtinvoke(A.ui.dim(zdim).slicelabel2, 'setVisible(Z)', true);
      awtinvoke(A.ui.dim(zdim).slicelabel3, 'setVisible(Z)', true);
      %awtinvoke(A.ui.dim(zdim).panel, 'setMaximumSize', java.awt.Dimension(java.lang.Short.MAX_VALUE, 110));      
    end
    if A.state.z~=0
      awtinvoke(A.ui.dim(A.state.z).scrollbar2, 'setVisible(Z)', false);
      awtinvoke(A.ui.dim(A.state.z).scrollbar3, 'setVisible(Z)', false);    
      awtinvoke(A.ui.dim(A.state.z).slicelabel2, 'setVisible(Z)', false);
      awtinvoke(A.ui.dim(A.state.z).slicelabel3, 'setVisible(Z)', false);
      %awtinvoke(A.ui.dim(A.state.z).panel, 'setMaximumSize', java.awt.Dimension(java.lang.Short.MAX_VALUE, 70));
    end
    A.state.z=zdim;
    h.put('slicer',A);
  end
end

A.ui.mainpanel.updateUI();
%fire update event
process_callbacks(A.callbacks, hObj, A.state);
