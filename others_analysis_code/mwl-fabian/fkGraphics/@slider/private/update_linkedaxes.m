function update_linkedaxes( S )


xl = S.center + [-0.5 0.5]*S.windowsize;

for k=1:numel(S.linkedaxes)
  
  %temporarily disable listener
  set( S.linkedaxes(k).listeners(1), 'Enabled', 'off' );
  
  set( S.linkedaxes(k).axes, 'XLim', xl );
  
  %enable listener
  set( S.linkedaxes(k).listeners(1), 'Enabled', 'on' );
  
end