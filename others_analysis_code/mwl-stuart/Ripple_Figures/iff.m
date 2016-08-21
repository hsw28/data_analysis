%%Artificial if for use in anonymous functions
%TRUE and FALSE are function handles.
function RESULT = iff(CONDITION,TRUE,FALSE)
  if CONDITION
    RESULT = TRUE;
  else
    RESULT = FALSE;
  end
end